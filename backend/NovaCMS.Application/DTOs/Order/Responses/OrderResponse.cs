using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Order.Responses
{
	public class OrderResponse
	{
		public int OrderId { get; set; }

		public int FullName { get; set; }

		public DateTime? OrderDate { get; set; }

		public DateTime RentalStartDate { get; set; }

		public DateTime RentalEndDate { get; set; }

		public string? ReferenceNo { get; set; }

		public string? Note { get; set; }

		public decimal TotalAmount { get; set; }

		public string? Status { get; set; }
	}
}
