using NovaCMS.Application.DTOs.Category.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
	public interface ICategoryService
	{
		Task<IEnumerable<CategoryResponse>> GetAllCategories();
	}
}
