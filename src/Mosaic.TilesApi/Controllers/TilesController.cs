#nullable disable
using AutoMapper;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Mosaic.TilesApi.Data;
using Mosaic.TilesApi.Models;

namespace Mosaic.TilesApi.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class TilesController : ControllerBase
    {
        private const string PubsubName = "pubsub";
        private readonly TilesDbContext _context;
        private readonly DaprClient _dapr;
        private readonly IMapper _mapper;

        public TilesController(TilesDbContext context, DaprClient dapr, IMapper mapper)
        {
            _context = context;
            _dapr = dapr;
            _mapper = mapper;
        }

        // GET: /Tiles
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TileReadDto>>> GetAllTiles()
        {
            return _mapper.Map<List<TileEntity>, List<TileReadDto>>(await _context.Tiles.ToListAsync());
        }

        // GET: /Tiles/5
        [HttpGet("{id}")]
        public async Task<ActionResult<TileReadDto>> GetTile(string id)
        {
            var tile = await _context.Tiles.FindAsync(id);

            if (tile == null)
            {
                return NotFound();
            }

            return _mapper.Map<TileEntity, TileReadDto>(tile);
        }

        // PUT: /Tiles/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutTile(int id, TileUpdateDto tile)
        {
            if (id != tile.Id)
            {
                return BadRequest();
            }
            var entity = _mapper.Map<TileUpdateDto, TileEntity>(tile);
            _context.Entry(entity).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();

                var newTile = _mapper.Map<TileReadDto>(entity);
                await _dapr.PublishEventAsync(PubsubName, TileEvents.TileUpdated, 
                    new TileUpdatedEvent
                    {
                        TileId = tile.Id,
                        Width = tile.Width,
                        Aspect = tile.Aspect,
                        Height = tile.Height,
                        AverageColor = tile.AverageColor,
                    });
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!TileExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: /Tiles
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<TileReadDto>> PostTile(TileCreateDto tile)
        {
            var entity = _mapper.Map<TileCreateDto, TileEntity>(tile);
            _context.Tiles.Add(entity);

            await _context.SaveChangesAsync();
            TileReadDto newTile = _mapper.Map<TileReadDto>(entity);
            await _dapr.PublishEventAsync(PubsubName, TileEvents.TileCreated, new TileCreatedEvent
            {
                TileId = newTile.Id,
                SourceId=newTile.SourceId,
                Source = newTile.Source
            });

            return CreatedAtAction("GetTile", new { id = newTile.Id }, newTile);
        }

        // DELETE: /Tiles/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTile(int id)
        {
            var tile = await _context.Tiles.FindAsync(id);
            if (tile == null)
            {
                return NotFound();
            }

            _context.Tiles.Remove(tile);
            await _context.SaveChangesAsync();
            await _dapr.PublishEventAsync(PubsubName, TileEvents.TileDeleted, new TileDeletedEvent { TileId = tile.Id });

            return NoContent();
        }

        private bool TileExists(int id)
        {
            return _context.Tiles.Any(e => e.Id == id);
        }
    }
}
