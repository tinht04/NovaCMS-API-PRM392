using Microsoft.EntityFrameworkCore;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Domain.Entities;
using NovaCMS.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Infrastructure.Repositories
{
	public class EquipmentItemRepository : GenericRepository<EquipmentItem>, IEquipmentItemRepository
	{
		private readonly NovaCMSDBContext _context;
		public EquipmentItemRepository(NovaCMSDBContext context) : base(context)
		{
			_context = context;
		}

		public async Task<bool> CheckAvailabilityAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity)
		{
			var availableCount = await GetAvailableStockAsync(equipmentId, startDate, endDate);
			return availableCount >= quantity;
		}

		public async Task<List<EquipmentItem>> GetAvailableItemsAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity)
		{
			var availableItems = await _context.EquipmentItems
				.Where(ei => ei.EquipmentId == equipmentId &&
						   ei.Status == "Available" &&
						   !ei.RentalOrderDetails.Any(rod =>
							   rod.RentalStartDate < endDate &&
							   rod.RentalEndDate > startDate &&
							   rod.ReturnDate == null)) // Chưa được trả
				.Take(quantity)
				.ToListAsync();

			return availableItems;
		}

		public async Task<int> GetAvailableStockAsync(int equipmentId, DateTime startDate, DateTime endDate)
		{
			var availableCount = await _context.EquipmentItems
				.Where(ei => ei.EquipmentId == equipmentId &&
						   ei.Status == "Available" &&
						   !ei.RentalOrderDetails.Any(rod =>
							   rod.RentalStartDate < endDate &&
							   rod.RentalEndDate > startDate &&
							   rod.ReturnDate == null))
				.CountAsync();

			return availableCount;
		}

        public async Task<int> GetAvailableEquipmentsAsync()
        {
            return await _context.EquipmentItems
                .CountAsync(e => e.Status == "Available");
        }
    }
}
