using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.RentalOrder.Requests
{
	public class DeliveryInfoDto
	{
		[Required]
		public string DeliveryMethod { get; set; } = string.Empty; // "pickup" hoặc "delivery"

		public string? DeliveryAddress { get; set; }

		public DateTime? PreferredDeliveryTime { get; set; }

		public string? DeliveryNotes { get; set; }
	}
}
