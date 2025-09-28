using NovaCMS.Application.DTOs.RentalOrder.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.RentalOrder.Responses
{
	public class RentalOrderResponse
	{
		public int OrderId { get; set; }
		public string ReferenceNo { get; set; } = string.Empty;
		public DateTime OrderDate { get; set; }
		public string Status { get; set; } = string.Empty;
		public decimal TotalAmount { get; set; }
		public List<RentalOrderDetailResponse> OrderDetails { get; set; } = new();
		public CustomerInfoDto CustomerInfo { get; set; } = new();
		public DeliveryInfoDto DeliveryInfo { get; set; } = new();
	}
}
