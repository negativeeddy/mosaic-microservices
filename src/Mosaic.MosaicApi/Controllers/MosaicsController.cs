using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Mosaic.MosaicApi.Controllers;

[ApiController]
public class MosaicsController : ControllerBase
{
    private readonly DaprClient _daprClient;

    public MosaicsController(DaprClient dapr)
    {
        _daprClient = dapr;
    }

    // GET api/<MosaicController>/5
    [HttpGet("[controller]/mosaics/{id}")]
    public MosaicDetails Get(string id)
    {
        return new MosaicDetails
        {
            Id = id,
            SourceId = new TileId("demo", "123"),
            HorizontalTileCount = 5,
            VerticalTileCount = 5,
            TileDetails = new TileId[0]
        };
    }

    // POST api/<MosaicController>
    [Route("[controller]/create")]
    [HttpPost]
    public async Task<ActionResult> Post([FromBody] MosaicOptions value)
    {
        return Created("5",
            new MosaicDetails
            {
                Id = "5",
                SourceId = value.SourceId,
                HorizontalTileCount = value.HorizontalTileCount,
                VerticalTileCount = value.VerticalTileCount,
                TileDetails = new TileId[value.HorizontalTileCount * value.VerticalTileCount]
            });
    }

    // PUT api/<MosaicController>/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody] string value)
    {
    }

    // DELETE api/<MosaicController>/5
    [HttpDelete("{id}")]
    public void Delete(int id)
    {
    }
}
