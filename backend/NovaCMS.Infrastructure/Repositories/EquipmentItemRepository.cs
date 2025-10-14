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
        private readonly IRedisService _redisService;
        public EquipmentItemRepository(NovaCMSDBContext context, IRedisService redisService) : base(context)
		{
			_context = context;
            _redisService = redisService;
        }

		public async Task<bool> CheckAvailabilityAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity)
		{
			var availableCount = await GetAvailableStockAsync(equipmentId, startDate, endDate);
			return availableCount >= quantity;
		}

        private async Task<List<EquipmentItem>> GetPotentiallyAvailableItemsAsync(int equipmentId, DateTime startDate, DateTime endDate)
        {
            return await _context.EquipmentItems
                .Where(ei => ei.EquipmentId == equipmentId &&
                             ei.Status == "Available" &&
                             !ei.RentalOrderDetails.Any(rod =>
                                 rod.RentalStartDate < endDate &&
                                 rod.RentalEndDate > startDate &&
                                 rod.ReturnDate == null))
                .ToListAsync();
        }

        public async Task<List<EquipmentItem>> GetAvailableItemsAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity)
        {
            // Lấy TẤT CẢ các item có thể phù hợp từ DB
            var potentiallyAvailableItems = await GetPotentiallyAvailableItemsAsync(equipmentId, startDate, endDate);

            // Lọc những item không bị giữ trong Redis
            var trulyAvailableItems = new List<EquipmentItem>();
            foreach (var item in potentiallyAvailableItems)
            {
                var key = $"reservation:item:{item.ItemId}";
                if (!await _redisService.ExistsAsync(key))
                {
                    trulyAvailableItems.Add(item);
                }
            }

            // Cuối cùng, lấy đúng số lượng cần thiết
            return trulyAvailableItems.Take(quantity).ToList();
        }

        public async Task<int> GetAvailableStockAsync(int equipmentId, DateTime startDate, DateTime endDate)
        {
            // Lấy TẤT CẢ các item có thể phù hợp từ DB
            var potentiallyAvailableItems = await GetPotentiallyAvailableItemsAsync(equipmentId, startDate, endDate);

            // Đếm số lượng item không bị giữ trong Redis
            int availableCount = 0;
            foreach (var item in potentiallyAvailableItems)
            {
                var key = $"reservation:item:{item.ItemId}";
                if (!await _redisService.ExistsAsync(key))
                {
                    availableCount++;
                }
            }

            return availableCount;
        }

        public async Task<int> GetAvailableEquipmentsAsync()
        {
            return await _context.EquipmentItems
                .CountAsync(e => e.Status == "Available");
        }
    }
}
