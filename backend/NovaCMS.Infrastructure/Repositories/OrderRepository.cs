using Microsoft.EntityFrameworkCore;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.RentalOrder;
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
	public class OrderRepository : GenericRepository<RentalOrder>, IOrderRepository
	{
		private readonly NovaCMSDBContext _context;

		public OrderRepository(NovaCMSDBContext context) : base(context)
		{
			_context = context;
		}

		public async Task<string> GenerateReferenceNoAsync()
		{
			var today = DateTime.Now;
			var prefix = $"RO{today:yyyyMMdd}";

			var lastOrder = await _context.RentalOrders
				.Where(ro => ro.ReferenceNo!.StartsWith(prefix))
				.OrderByDescending(ro => ro.ReferenceNo)
				.FirstOrDefaultAsync();

			if (lastOrder == null)
			{
				return $"{prefix}001";
			}

			var lastNumber = int.Parse(lastOrder.ReferenceNo!.Substring(prefix.Length));
			return $"{prefix}{(lastNumber + 1):D3}";
		}

		public async Task<List<RentalOrder>> GetOrdersByUserIdAsync(int userId)
		{
			return await _context.RentalOrders
				.Include(ro => ro.RentalOrderDetails)
					.ThenInclude(rod => rod.EquipmentItem)
						.ThenInclude(ei => ei!.Equipment)
				.Where(ro => ro.UserId == userId)
				.OrderByDescending(ro => ro.OrderDate)
				.ToListAsync();
		}

		public async Task<RentalOrder> GetOrderWithDetailsAsync(int orderId)
		{
			return await _context.RentalOrders
				.Include(ro => ro.RentalOrderDetails)
					.ThenInclude(rod => rod.EquipmentItem)
						.ThenInclude(ei => ei!.Equipment)
							.ThenInclude(e => e.EquipmentImages)
				.Include(ro => ro.User)
				.FirstOrDefaultAsync(ro => ro.OrderId == orderId) ?? new RentalOrder();
		}

		public async Task<(List<RentalOrder> orders, int totalCount)> GetFilteredOrdersAsync(OrderFilterDto filter)
		{
			var query = _context.RentalOrders
				.Include(ro => ro.User)
				.Include(ro => ro.RentalOrderDetails)
					.ThenInclude(rod => rod.EquipmentItem)
						.ThenInclude(ei => ei!.Equipment)
							.ThenInclude(e => e.EquipmentImages)
				.AsQueryable();

			// Apply filters
			if (filter.UserId.HasValue)
			{
				query = query.Where(ro => ro.UserId == filter.UserId.Value);
			}

			if (!string.IsNullOrEmpty(filter.ReferenceNo))
			{
				query = query.Where(ro => ro.ReferenceNo!.Contains(filter.ReferenceNo));
			}

			if (!string.IsNullOrEmpty(filter.Status))
			{
				query = query.Where(ro => ro.Status == filter.Status);
			}

			if (filter.OrderDateFrom.HasValue)
			{
				query = query.Where(ro => ro.OrderDate >= filter.OrderDateFrom.Value);
			}

			if (filter.OrderDateTo.HasValue)
			{
				query = query.Where(ro => ro.OrderDate <= filter.OrderDateTo.Value.AddDays(1));
			}

			if (filter.RentalStartDateFrom.HasValue)
			{
				query = query.Where(ro => ro.RentalOrderDetails.Any(rod => rod.RentalStartDate >= filter.RentalStartDateFrom.Value));
			}

			if (filter.RentalStartDateTo.HasValue)
			{
				query = query.Where(ro => ro.RentalOrderDetails.Any(rod => rod.RentalStartDate <= filter.RentalStartDateTo.Value));
			}

			if (filter.RentalEndDateFrom.HasValue)
			{
				query = query.Where(ro => ro.RentalOrderDetails.Any(rod => rod.RentalEndDate >= filter.RentalEndDateFrom.Value));
			}

			if (filter.RentalEndDateTo.HasValue)
			{
				query = query.Where(ro => ro.RentalOrderDetails.Any(rod => rod.RentalEndDate <= filter.RentalEndDateTo.Value));
			}

			if (filter.MinTotalAmount.HasValue)
			{
				query = query.Where(ro => ro.TotalAmount >= filter.MinTotalAmount.Value);
			}

			if (filter.MaxTotalAmount.HasValue)
			{
				query = query.Where(ro => ro.TotalAmount <= filter.MaxTotalAmount.Value);
			}

			if (!string.IsNullOrEmpty(filter.CustomerName))
			{
				query = query.Where(ro => ro.User.FullName!.Contains(filter.CustomerName));
			}

			if (!string.IsNullOrEmpty(filter.CustomerEmail))
			{
				query = query.Where(ro => ro.User.Email!.Contains(filter.CustomerEmail));
			}

			if (!string.IsNullOrEmpty(filter.CustomerPhone))
			{
				query = query.Where(ro => ro.User.PhoneNumber!.Contains(filter.CustomerPhone));
			}

			if (!string.IsNullOrEmpty(filter.SearchTerm))
			{
				query = query.Where(ro =>
					ro.ReferenceNo!.Contains(filter.SearchTerm) ||
					ro.User.FullName!.Contains(filter.SearchTerm) ||
					ro.User.Email!.Contains(filter.SearchTerm) ||
					ro.User.PhoneNumber!.Contains(filter.SearchTerm));
			}

			// Get total count before pagination
			var totalCount = await query.CountAsync();

			// Apply sorting
			query = (filter.SortBy?.ToLower(), filter.SortOrder?.ToLower()) switch
			{
				("orderdate", "asc") => query.OrderBy(ro => ro.OrderDate),
				("orderdate", "desc") => query.OrderByDescending(ro => ro.OrderDate),
				("totalamount", "asc") => query.OrderBy(ro => ro.TotalAmount),
				("totalamount", "desc") => query.OrderByDescending(ro => ro.TotalAmount),
				("referenceno", "asc") => query.OrderBy(ro => ro.ReferenceNo),
				("referenceno", "desc") => query.OrderByDescending(ro => ro.ReferenceNo),
				("status", "asc") => query.OrderBy(ro => ro.Status),
				("status", "desc") => query.OrderByDescending(ro => ro.Status),
				_ => query.OrderByDescending(ro => ro.OrderDate) // Default sorting
			};

			// Apply pagination
			var orders = await query
				.Skip((filter.PageNumber - 1) * filter.PageSize)
				.Take(filter.PageSize)
				.ToListAsync();

			return (orders, totalCount);
		}

		public async Task<List<string>> GetOrderStatusesAsync()
		{
			return await _context.RentalOrders
				.Where(ro => !string.IsNullOrEmpty(ro.Status))
				.Select(ro => ro.Status!)
				.Distinct()
				.OrderBy(s => s)
				.ToListAsync();
		}
	}
}