using AutoMapper;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.RentalOrder;
using NovaCMS.Application.DTOs.RentalOrder.Requests;
using NovaCMS.Application.DTOs.RentalOrder.Responses;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Services
{
	public class OrderService : IOrderService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IMapper _mapper;

		public OrderService(IUnitOfWork unitOfWork, IMapper mapper)
		{
			_unitOfWork = unitOfWork;
			_mapper = mapper;
		}

		public async Task<RentalOrderSummaryDto> CalculateOrderSummaryAsync(CreateRentalOrderRequest createOrderDto)
		{
			var summary = new RentalOrderSummaryDto();
			var itemSummaries = new List<OrderItemSummaryDto>();

			foreach (var item in createOrderDto.Items)
			{
				var equipment = await _unitOfWork.Equipments.GetByIdAsync(item.EquipmentId);
				if (equipment == null) continue;

				var rentalDays = (item.RentalEndDate - item.RentalStartDate).Days;
				if (rentalDays <= 0) rentalDays = 1;

				var availableStock = await _unitOfWork.EquipmentItems.GetAvailableStockAsync(
					item.EquipmentId, item.RentalStartDate, item.RentalEndDate);

				var itemSummary = new OrderItemSummaryDto
				{
					EquipmentId = equipment.EquipmentId,
					EquipmentName = equipment.Name,
					Brand = equipment.Brand,
					ImageUrl = equipment.EquipmentImages?.FirstOrDefault(img => img.IsPrimary == true)?.ImageUrl,
					PricePerDay = equipment.PricePerDay,
					DepositFee = equipment.DepositFee,
					Quantity = item.Quantity,
					RentalDays = rentalDays,
					ItemTotal = equipment.PricePerDay * rentalDays * item.Quantity,
					IsAvailable = availableStock >= item.Quantity,
					AvailableStock = availableStock
				};

				itemSummaries.Add(itemSummary);
			}

			summary.Items = itemSummaries;
			summary.SubTotal = itemSummaries.Sum(i => i.ItemTotal);
			summary.DiscountAmount = 0; // Implement discount logic if needed
			summary.DeliveryFee = createOrderDto.DeliveryInfo.DeliveryMethod == "delivery" ? 50000 : 0;
			summary.TotalAmount = summary.SubTotal - summary.DiscountAmount + summary.DeliveryFee;
			summary.TotalDays = createOrderDto.Items.Any() ?
				createOrderDto.Items.Max(i => (i.RentalEndDate - i.RentalStartDate).Days) : 0;
			summary.EstimatedStartDate = createOrderDto.Items.Any() ?
				createOrderDto.Items.Min(i => i.RentalStartDate) : DateTime.Now;
			summary.EstimatedEndDate = createOrderDto.Items.Any() ?
				createOrderDto.Items.Max(i => i.RentalEndDate) : DateTime.Now;

			return summary;
		}

		public async Task<bool> CheckEquipmentAvailabilityAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity)
		{
			return await _unitOfWork.EquipmentItems.CheckAvailabilityAsync(equipmentId, startDate, endDate, quantity);
		}

		public async Task<RentalOrderResponse> CreateOrderAsync(CreateRentalOrderRequest createOrderDto)
		{
			// Validate availability
			foreach (var item in createOrderDto.Items)
			{
				var isAvailable = await CheckEquipmentAvailabilityAsync(
					item.EquipmentId, item.RentalStartDate, item.RentalEndDate, item.Quantity);

				if (!isAvailable)
					throw new InvalidOperationException($"Equipment {item.EquipmentId} is not available for the selected dates");
			}

			// Create rental order
			var referenceNo = await _unitOfWork.Orders.GenerateReferenceNoAsync();
			var summary = await CalculateOrderSummaryAsync(createOrderDto);

			var rentalOrder = new RentalOrder
			{
				UserId = createOrderDto.UserId,
				OrderDate = DateTime.Now,
				ReferenceNo = referenceNo,
				Note = createOrderDto.Note,
				TotalAmount = summary.TotalAmount,
				Status = "Pending" // Pending, Confirmed, InProgress, Completed, Cancelled
			};
			var createdOrder = await _unitOfWork.Orders.AddAsync(rentalOrder);
			await _unitOfWork.SaveChangesAsync();

			// Create order details and assign equipment items
			foreach (var item in createOrderDto.Items)
			{
				var equipment = await _unitOfWork.Equipments.GetByIdAsync(item.EquipmentId);
				var availableItems = await _unitOfWork.EquipmentItems.GetAvailableItemsAsync(
					item.EquipmentId, item.RentalStartDate, item.RentalEndDate, item.Quantity);

				foreach (var equipmentItem in availableItems)
				{
					var orderDetail = new RentalOrderDetail
					{
						OrderId = createdOrder.OrderId,
						EquipmentId = item.EquipmentId,
						EquipmentItemId = equipmentItem.ItemId,
						RentalStartDate = item.RentalStartDate,
						RentalEndDate = item.RentalEndDate,
						PricePerDay = equipment!.PricePerDay,
						DepositFee = equipment.DepositFee
					};

					await _unitOfWork.OrderDetails.AddAsync(orderDetail);
				}
			}

			await _unitOfWork.SaveChangesAsync();

			return await GetOrderByIdAsync(createdOrder.OrderId) ?? new RentalOrderResponse();
		}

		public async Task<RentalOrderResponse?> GetOrderByIdAsync(int orderId)
		{
			var order = await _unitOfWork.Orders.GetOrderWithDetailsAsync(orderId);
			if (order == null) return null;

			return _mapper.Map<RentalOrderResponse>(order);
		}

		public async Task<List<RentalOrderResponse>> GetOrdersByUserIdAsync(int userId)
		{
			var orders = await _unitOfWork.Orders.GetOrdersByUserIdAsync(userId);
			return _mapper.Map<List<RentalOrderResponse>>(orders);
		}

		public async Task<PaginationResponse<RentalOrderResponse>> GetAllOrdersAsync(OrderFilterDto filter)
		{
			var (orders, totalCount) = await _unitOfWork.Orders.GetFilteredOrdersAsync(filter);

			var orderResponses = _mapper.Map<List<RentalOrderResponse>>(orders);

			var paginationResponse = new PaginationResponse<RentalOrderResponse>();
			return paginationResponse.Paginate(orderResponses, totalCount, filter.PageNumber, filter.PageSize);
		}

		public async Task<List<string>> GetOrderStatusesAsync()
		{
			return await _unitOfWork.Orders.GetOrderStatusesAsync();
		}
	}
}