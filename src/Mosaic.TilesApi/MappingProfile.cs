using AutoMapper;
using Mosaic.TilesApi.Data;
using Mosaic.TilesApi.Models;

namespace Mosaic.TilesApi
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<TileEntity, TileReadDto>(); 
            CreateMap<TileCreateDto, TileEntity>(); 
            CreateMap<TileUpdateDto, TileEntity>();
        }
    }
}
