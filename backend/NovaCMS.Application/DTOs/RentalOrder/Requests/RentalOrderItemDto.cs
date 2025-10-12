using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.RentalOrder.Requests
{
	public class RentalOrderItemDto
	{
		[Required]
		public int EquipmentId { get; set; }

		[Required]
		public DateTime RentalStartDate { get; set; }

		[Required]
		public DateTime RentalEndDate { get; set; }

		public int Quantity { get; set; } = 1;
	}
}
