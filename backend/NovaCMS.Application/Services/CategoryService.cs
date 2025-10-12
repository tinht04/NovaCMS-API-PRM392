using AutoMapper;
using NovaCMS.Application.DTOs.Category.Responses;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Services
{
	public class CategoryService : ICategoryService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IMapper _mapper;
		public CategoryService(IUnitOfWork unitOfWork, IMapper mapper)
		{
			_unitOfWork = unitOfWork;
			_mapper = mapper;
		}

		public async Task<IEnumerable<CategoryResponse>> GetAllCategories()
		{
			var list = await _unitOfWork.Categories.GetAllAsync();
			return _mapper.Map<IEnumerable<CategoryResponse>>(list);
		}
	}
}
