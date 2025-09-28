using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.RentalOrder.Requests
{
	public class CreateRentalOrderRequest
	{
		[Required]
		public int UserId { get; set; }

		[Required]
		public List<RentalOrderItemDto> Items { get; set; } = new();

		public string? Note { get; set; }

		[Required]
		public CustomerInfoDto CustomerInfo { get; set; } = new();

		[Required]
		public DeliveryInfoDto DeliveryInfo { get; set; } = new();
	}
}
