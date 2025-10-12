using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.RentalOrder
{
	public class OrderFilterDto
	{
		public int? UserId { get; set; }
		public string? ReferenceNo { get; set; }
		public string? Status { get; set; }
		public DateTime? OrderDateFrom { get; set; }
		public DateTime? OrderDateTo { get; set; }
		public DateTime? RentalStartDateFrom { get; set; }
		public DateTime? RentalStartDateTo { get; set; }
		public DateTime? RentalEndDateFrom { get; set; }
		public DateTime? RentalEndDateTo { get; set; }
		public decimal? MinTotalAmount { get; set; }
		public decimal? MaxTotalAmount { get; set; }
		public string? CustomerName { get; set; }
		public string? CustomerEmail { get; set; }
		public string? CustomerPhone { get; set; }
		public string? SearchTerm { get; set; } // Tìm kiếm trong tên khách hàng, email, số điện thoại, reference no
		public string? SortBy { get; set; } = "OrderDate"; // OrderDate, TotalAmount, ReferenceNo, Status
		public string? SortOrder { get; set; } = "desc"; // asc, desc
		public int PageNumber { get; set; } = 1;
		public int PageSize { get; set; } = 10;
	}
}
