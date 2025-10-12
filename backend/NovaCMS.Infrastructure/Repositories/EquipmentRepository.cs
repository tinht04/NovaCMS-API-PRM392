using Microsoft.EntityFrameworkCore;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.Equipment;
using NovaCMS.Application.DTOs.Equipment.Responses;
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
	public class EquipmentRepository : GenericRepository<Equipment>, IEquipmentRepository
	{
		private readonly NovaCMSDBContext _context;
		public EquipmentRepository(NovaCMSDBContext context) : base(context)
		{
			_context = context;
		}


		public async Task<List<string>> GetAvailableBrandsAsync()
		{
			return await _context.Equipments
				.Where(e => !string.IsNullOrEmpty(e.Brand))
				.Select(e => e.Brand!)
				.Distinct()
				.OrderBy(b => b)
				.ToListAsync();
		}

        public async Task<Equipment> GetEquipmentByIdAsync(int id)
		{
			return await _context.Equipments.Include(e => e.Category)
				.Include(e => e.EquipmentImages)
				.FirstOrDefaultAsync(e => e.EquipmentId == id);
		}

		public async Task<(List<Equipment> items, int totalCount)> GetFilteredEquipmentAsync(EquipmentFilterDto filter)
		{
			var query = _context.Equipments
				.Include(e => e.Category)
				.Include(e => e.EquipmentImages)
				.AsQueryable();

			// Apply filters
			if (!string.IsNullOrEmpty(filter.SearchTerm))
			{
				query = query.Where(e => e.Name.ToLower().Contains(filter.SearchTerm.ToLower()) ||
									   e.Brand.ToLower().Contains(filter.SearchTerm.ToLower()) ||
									   e.Description.ToLower().Contains(filter.SearchTerm.ToLower()));
			}

			if (filter.CategoryId.HasValue)
			{
				query = query.Where(e => e.CategoryId == filter.CategoryId.Value);
			}

			if (!string.IsNullOrWhiteSpace(filter.Brand))
			{
				query = query.Where(e => e.Brand.ToLower().Contains(filter.Brand));
			}
			if (filter.MinPrice.HasValue)
			{
				query = query.Where(e => e.PricePerDay >= filter.MinPrice.Value);
			}
			if (filter.MaxPrice.HasValue)
			{
				query = query.Where(e => e.PricePerDay <= filter.MaxPrice.Value);
			}
			if (filter.IsAvailable.HasValue)
			{
				if (filter.IsAvailable.Value)
				{
					query = query.Where(e => e.Stock > 0 && e.Status == "Available");
				}
				else
				{
					query = query.Where(e => e.Stock == 0 || e.Status != "Available");
				}
			}

			// Get total count before pagination
			var totalCount = await query.CountAsync();

			// Sorting
			query = filter.SortBy switch
			{
				"price_asc" => query.OrderBy(e => e.PricePerDay),
				"price_desc" => query.OrderByDescending(e => e.PricePerDay),
				"name_asc" => query.OrderBy(e => e.Name),
				"name_desc" => query.OrderByDescending(e => e.Name),
				"newest" => query.OrderByDescending(e => e.EquipmentId), // Assuming EquipmentId is incremental
				_ => query.OrderByDescending(e => e.EquipmentId), // Default sorting
			};

			// Apply pagination
			var items = await query
				.Skip((filter.PageNumber - 1) * filter.PageSize)
				.Take(filter.PageSize)
				.ToListAsync();

			return (items, totalCount);
		}

		public async Task<(decimal MinPrice, decimal MaxPrice)> GetPriceRangeAsync()
		{
			var prices = await _context.Equipments
				.Where(e => e.PricePerDay > 0)
				.Select(e => e.PricePerDay)
				.ToListAsync();

			if (!prices.Any())
				return (0, 0);

			return (prices.Min(), prices.Max());
		}

		public async Task<List<Equipment>> GetRelatedEquipmentsAsync(int id, int categoryId)
		{
			return await _context.Equipments.Where(e => e.CategoryId == categoryId && e.EquipmentId != id)
				.Skip(0)
				.Take(4).ToListAsync();
		}

        public async Task<List<Equipment>> GetAllWithRelationsAsync()
        {
            return await _context.Equipments
                .Include(e => e.Category)
                .Include(e => e.EquipmentImages)
				.Include(e => e.EquipmentItems)
                .ToListAsync();
        }
    }
}
