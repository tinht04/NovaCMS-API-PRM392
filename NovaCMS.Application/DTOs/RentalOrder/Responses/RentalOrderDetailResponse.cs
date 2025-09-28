using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.RentalOrder.Responses
{
	public class RentalOrderDetailResponse
	{
		public int OrderDetailId { get; set; }
		public int EquipmentId { get; set; }
		public string EquipmentName { get; set; } = string.Empty;
		public string? Brand { get; set; }
		public int? EquipmentItemId { get; set; }
		public string? SerialNumber { get; set; }
		public DateTime RentalStartDate { get; set; }
		public DateTime RentalEndDate { get; set; }
		public decimal PricePerDay { get; set; }
		public decimal? DepositFee { get; set; }
		public string? ImageUrl { get; set; }
	}
}
