using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.EquipmentImage.Responses
{
	public class EquipmentImageResponse
	{
		public int ImageId { get; set; }

		//public int EquipmentId { get; set; }

		public string ImageUrl { get; set; } = null!;

		public bool? IsPrimary { get; set; }

		public int? SortOrder { get; set; }
	}
}
