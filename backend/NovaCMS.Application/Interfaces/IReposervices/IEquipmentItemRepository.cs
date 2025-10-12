using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
	public interface IEquipmentItemRepository : IGenericRepository<EquipmentItem>
	{
		Task<List<EquipmentItem>> GetAvailableItemsAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity);
		Task<bool> CheckAvailabilityAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity);
		Task<int> GetAvailableStockAsync(int equipmentId, DateTime startDate, DateTime endDate);
        Task<int> GetAvailableEquipmentsAsync();
	}
}
