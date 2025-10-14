using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.RentalOrder;
using NovaCMS.Application.DTOs.RentalOrder.Requests;
using NovaCMS.Application.DTOs.RentalOrder.Responses;
using NovaCMS.Application.DTOs.VnPay;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
	public interface IOrderService
	{
		Task<RentalOrderSummaryDto> CalculateOrderSummaryAsync(CreateRentalOrderRequest createOrderDto);
		Task<RentalOrderResponse> CreateOrderAsync(CreateRentalOrderRequest createOrderDto);
		Task<RentalOrderResponse?> GetOrderByIdAsync(int orderId);
		Task<List<RentalOrderResponse>> GetOrdersByUserIdAsync(int userId);
		Task<bool> CheckEquipmentAvailabilityAsync(int equipmentId, DateTime startDate, DateTime endDate, int quantity);
		Task<PaginationResponse<RentalOrderResponse>> GetAllOrdersAsync(OrderFilterDto filter);
		Task<List<string>> GetOrderStatusesAsync();
		Task<RentalOrderResponse> CreateOrderFromReservationAsync(string reservationId, PaymentResponseModel paymentDetails);

    }
}
