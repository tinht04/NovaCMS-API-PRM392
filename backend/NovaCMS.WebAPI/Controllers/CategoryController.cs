using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs.Category.Responses;
using NovaCMS.Application.Interfaces.IServices;

namespace NovaCMS.API.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class CategoryController : ControllerBase
	{
		private readonly ICategoryService _categoryService;

		public CategoryController(ICategoryService categoryService)
		{
			_categoryService = categoryService;
		}

		[HttpGet]
		public async Task<IActionResult> GetAllCategories()
		{
			var categories = await _categoryService.GetAllCategories();
			return Ok(new ApiResponse<IEnumerable<CategoryResponse>>("Successfully!", categories));
		}
		 
	}
}
