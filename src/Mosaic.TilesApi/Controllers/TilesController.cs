#nullable disable
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Mosaic.TilesApi.Data;

namespace Mosaic.TilesApi.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class TilesController : ControllerBase
    {
        private readonly TilesDbContext _context;

        public TilesController(TilesDbContext context)
        {
            _context = context;
        }

        // GET: api/Tiles
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Tile>>> GetTile()
        {
            return await _context.Tiles.ToListAsync();
        }

        // GET: api/Tiles/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Tile>> GetTile(string id)
        {
            var tile = await _context.Tiles.FindAsync(id);

            if (tile == null)
            {
                return NotFound();
            }

            return tile;
        }

        // PUT: api/Tiles/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutTile(string id, Tile tile)
        {
            if (id != tile.Id)
            {
                return BadRequest();
            }

            _context.Entry(tile).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
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

        // POST: api/Tiles
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<Tile>> PostTile(Tile tile)
        {
            _context.Tiles.Add(tile);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (TileExists(tile.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetTile", new { id = tile.Id }, tile);
        }

        // DELETE: api/Tiles/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTile(string id)
        {
            var tile = await _context.Tiles.FindAsync(id);
            if (tile == null)
            {
                return NotFound();
            }

            _context.Tiles.Remove(tile);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool TileExists(string id)
        {
            return _context.Tiles.Any(e => e.Id == id);
        }
    }
}
