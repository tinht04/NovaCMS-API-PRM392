using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.Category.Responses;
using NovaCMS.Application.DTOs.Equipment;
using NovaCMS.Application.DTOs.Equipment.Responses;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Domain.Entities;
using System.Threading.Tasks;

namespace NovaCMS.API.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class EquipmentController : ControllerBase
	{
		private readonly IEquipmentService _equipmentService;
		
		public EquipmentController(IEquipmentService equipmentService)
		{
			_equipmentService = equipmentService;
		}

		[HttpGet]
		public async Task<IActionResult> GetAllEquipmentByFilter([FromQuery]EquipmentFilterDto equipmentFilterDto)
		{
			var list = await _equipmentService.GetFilteredEquipmentAsync(equipmentFilterDto);
			var result = new ApiResponse<PaginationResponse<EquipmentResponse>>("Successfully", list);

			return Ok(result);
		}

		[HttpGet("{id}")]
		public async Task<IActionResult> GetEquipmentById(int id)
		{
			var equipment = await _equipmentService.GetEquipmentByIdAsync(id);
			if (equipment == null)
			{
				return NotFound(new ApiResponse<CategoryResponse>($"Id{id} is not found!", new List<string>() { }, 404));
			}
			return Ok(new ApiResponse<EquipmentResponse>("Successfully!", equipment));
		}

		[HttpGet("brands")]
		public async Task<IActionResult> GetAvailableBrands()
		{
			var list = await _equipmentService.GetAvailableBrandsAsync();
			return Ok(list);
		}

		[HttpGet("rangePrice")]
		public async Task<IActionResult> GetRangePrice()
		{
			var result = await _equipmentService.GetPriceRangeAsync();

			return Ok(new decimal[] {result.MinPrice, result.MaxPrice});
		}

		[HttpGet("{id}/{categoryId}/related")]
		public async Task<IActionResult> GetRelatedEquipments(int id, int categoryId)
		{
			var result = await _equipmentService.GetRelatedEquipmentsAsync(id, categoryId);
			return Ok(new ApiResponse<List<EquipmentResponse>>("Successfully!", result));
		}
	}
}
