using NovaCMS.Application.DTOs.EquipmentImage.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Equipment.Responses
{
	public class EquipmentResponse
	{
		public int EquipmentId { get; set; }
		public string Name { get; set; } = null!;
		public string? Brand { get; set; }
		public string? Description { get; set; }
		public decimal PricePerDay { get; set; }
		public decimal? DepositFee { get; set; }
		public string? Status { get; set; }
		public int? Stock { get; set; }
		public string? CategoryName { get; set; }
        public string? ThumbNail { get; set; } //ThumbNail image url
        public List<EquipmentImageResponse> imageResponses { get; set; } = new();
		public double AverageRating { get; set; }
		public int ReviewCount { get; set; }
		public bool IsAvailable { get; set; }
		public string? Location { get; set; }
	}
}
