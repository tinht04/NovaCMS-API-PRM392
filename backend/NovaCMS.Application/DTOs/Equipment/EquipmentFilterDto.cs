using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Equipment
{
	public class EquipmentFilterDto
	{
		public string? SearchTerm { get; set; }
		public int? CategoryId { get; set; }
		public string? Brand { get; set; }
		public decimal? MinPrice { get; set; }
		public decimal? MaxPrice { get; set; }
		public bool? IsAvailable { get; set; }
		public int? MinRating { get; set; }
		public string? SortBy { get; set; } // "price_asc", "price_desc", "name_asc", "name_desc", "rating_desc", "newest"
		public int PageNumber { get; set; } = 1;
		public int PageSize { get; set; } = 10;
	}
}
