using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.Equipment;
using NovaCMS.Application.DTOs.Equipment.Responses;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
	public interface IEquipmentRepository : IGenericRepository<Equipment>
	{
		Task<(List<Equipment> items, int totalCount)> GetFilteredEquipmentAsync(EquipmentFilterDto filter);
		Task<Equipment> GetEquipmentByIdAsync(int id);
		Task<List<string>> GetAvailableBrandsAsync();
		Task<(decimal MinPrice, decimal MaxPrice)> GetPriceRangeAsync();
		Task<List<Equipment>> GetRelatedEquipmentsAsync(int id, int categoryId);
		Task<List<Equipment>> GetAllWithRelationsAsync();
    }
}
