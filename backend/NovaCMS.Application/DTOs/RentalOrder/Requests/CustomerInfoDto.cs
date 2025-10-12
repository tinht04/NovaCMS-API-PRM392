using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.RentalOrder.Requests
{
	public class CustomerInfoDto
	{
		[Required]
		public string FullName { get; set; } = string.Empty;

		[Required]
		[EmailAddress]
		public string Email { get; set; } = string.Empty;

		[Required]
		[Phone]
		public string PhoneNumber { get; set; } = string.Empty;

		public string? Address { get; set; }
	}
}
