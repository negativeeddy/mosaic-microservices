using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Mosaic.MosaicApi.Events;
using Mosaic.MosaicApi.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Mosaic.MosaicApi.Controllers;

[ApiController]
[Route("[controller]")]
public class MosaicsController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly DaprClient _daprClient;

    static Dictionary<string, MosaicDetails> mosaics = new Dictionary<string, MosaicDetails>();
    static int nextId = 1;

    public MosaicsController(DaprClient dapr)
    {
        _daprClient = dapr;
    }

    // GET api/<MosaicController>/5
    [HttpGet()]
    public IActionResult GetAll()
    {
        return Ok(mosaics.Values.ToArray());
    }


    // GET api/<MosaicController>/5
    [HttpGet("{id}")]
    public IActionResult GetById(string id)
    {
        if (mosaics.ContainsKey(id))
        {
            return Ok(mosaics[id]);
        }

        return NotFound();
    }

    // POST api/<MosaicController>
    [HttpPost]
    public async Task<ActionResult> Post([FromBody] MosaicOptions options)
    {
        MosaicDetails newMosaic = new MosaicDetails
        {
            Id = nextId++.ToString(),
            SourceId = options.SourceId,
            HorizontalTileCount = options.HorizontalTileCount,
            VerticalTileCount = options.VerticalTileCount,
            TileDetails = new TileId[options.HorizontalTileCount * options.VerticalTileCount]
        };

        mosaics.Add(newMosaic.Id, newMosaic);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCreatedEvent),
            new MosaicCreatedEvent(newMosaic.Id, options));

        return Created(newMosaic.Id, newMosaic);
    }

    // PUT api/<MosaicController>/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody] string value)
    {
        throw new NotImplementedException();
    }

    // DELETE api/<MosaicController>/5
    [HttpDelete("{id}")]
    public IActionResult Delete(string id)
    {
        if (mosaics.Remove(id))
        {
            return Ok();
        }
        return NotFound();
    }
}
