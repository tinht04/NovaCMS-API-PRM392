using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.RentalOrder;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
	public interface IOrderRepository : IGenericRepository<RentalOrder>
	{
		Task<string> GenerateReferenceNoAsync();
		Task<RentalOrder> GetOrderWithDetailsAsync(int orderId);
		Task<List<RentalOrder>> GetOrdersByUserIdAsync(int userId);
		Task<(List<RentalOrder> orders, int totalCount)> GetFilteredOrdersAsync(OrderFilterDto filter);
		Task<List<string>> GetOrderStatusesAsync();
	}
}