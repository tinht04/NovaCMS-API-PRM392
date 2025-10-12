using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.Equipment;
using NovaCMS.Application.DTOs.Equipment.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
	public interface IEquipmentService
	{
		Task<PaginationResponse<EquipmentResponse>> GetFilteredEquipmentAsync(EquipmentFilterDto filter);
		Task<EquipmentResponse?> GetEquipmentByIdAsync(int id);
		Task<List<string>> GetAvailableBrandsAsync();
		Task<(decimal MinPrice, decimal MaxPrice)> GetPriceRangeAsync();
		Task<List<EquipmentResponse>> GetRelatedEquipmentsAsync(int id, int categoryId);
	}
}
