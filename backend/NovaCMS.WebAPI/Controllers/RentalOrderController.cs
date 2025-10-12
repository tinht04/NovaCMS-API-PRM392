using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.RentalOrder;
using NovaCMS.Application.DTOs.RentalOrder.Requests;
using NovaCMS.Application.DTOs.RentalOrder.Responses;
using NovaCMS.Application.Interfaces.IServices;
using System.ComponentModel.DataAnnotations;

namespace NovaCMS.API.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class RentalOrderController : ControllerBase
	{
		private readonly IOrderService _orderService;

		public RentalOrderController(IOrderService orderService)
		{
			_orderService = orderService;
		}

		/// <summary>
		/// Lấy tất cả đơn hàng cho admin với filter và phân trang
		/// </summary>
		/// <param name="userId">ID người dùng (tùy chọn)</param>
		/// <param name="referenceNo">Số tham chiếu đơn hàng</param>
		/// <param name="status">Trạng thái đơn hàng</param>
		/// <param name="orderDateFrom">Ngày đặt hàng từ</param>
		/// <param name="orderDateTo">Ngày đặt hàng đến</param>
		/// <param name="rentalStartDateFrom">Ngày bắt đầu thuê từ</param>
		/// <param name="rentalStartDateTo">Ngày bắt đầu thuê đến</param>
		/// <param name="rentalEndDateFrom">Ngày kết thúc thuê từ</param>
		/// <param name="rentalEndDateTo">Ngày kết thúc thuê đến</param>
		/// <param name="minTotalAmount">Tổng tiền tối thiểu</param>
		/// <param name="maxTotalAmount">Tổng tiền tối đa</param>
		/// <param name="customerName">Tên khách hàng</param>
		/// <param name="customerEmail">Email khách hàng</param>
		/// <param name="customerPhone">Số điện thoại khách hàng</param>
		/// <param name="searchTerm">Từ khóa tìm kiếm</param>
		/// <param name="sortBy">Sắp xếp theo (OrderDate, TotalAmount, ReferenceNo, Status)</param>
		/// <param name="sortOrder">Thứ tự sắp xếp (asc, desc)</param>
		/// <param name="pageNumber">Số trang</param>
		/// <param name="pageSize">Kích thước trang</param>
		/// <returns>Danh sách đơn hàng đã được filter và phân trang</returns>
		[HttpGet("admin")]
		[ProducesResponseType(typeof(ApiResponse<PaginationResponse<RentalOrderResponse>>), StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		[ProducesResponseType(StatusCodes.Status500InternalServerError)]
		public async Task<IActionResult> GetAllOrdersForAdmin(
			[FromQuery] int? userId = null,
			[FromQuery] string? referenceNo = null,
			[FromQuery] string? status = null,
			[FromQuery] DateTime? orderDateFrom = null,
			[FromQuery] DateTime? orderDateTo = null,
			[FromQuery] DateTime? rentalStartDateFrom = null,
			[FromQuery] DateTime? rentalStartDateTo = null,
			[FromQuery] DateTime? rentalEndDateFrom = null,
			[FromQuery] DateTime? rentalEndDateTo = null,
			[FromQuery] decimal? minTotalAmount = null,
			[FromQuery] decimal? maxTotalAmount = null,
			[FromQuery] string? customerName = null,
			[FromQuery] string? customerEmail = null,
			[FromQuery] string? customerPhone = null,
			[FromQuery] string? searchTerm = null,
			[FromQuery] string sortBy = "OrderDate",
			[FromQuery] string sortOrder = "desc",
			[FromQuery] int pageNumber = 1,
			[FromQuery] int pageSize = 10)
		{
			try
			{
				var filter = new OrderFilterDto
				{
					UserId = userId,
					ReferenceNo = referenceNo,
					Status = status,
					OrderDateFrom = orderDateFrom,
					OrderDateTo = orderDateTo,
					RentalStartDateFrom = rentalStartDateFrom,
					RentalStartDateTo = rentalStartDateTo,
					RentalEndDateFrom = rentalEndDateFrom,
					RentalEndDateTo = rentalEndDateTo,
					MinTotalAmount = minTotalAmount,
					MaxTotalAmount = maxTotalAmount,
					CustomerName = customerName,
					CustomerEmail = customerEmail,
					CustomerPhone = customerPhone,
					SearchTerm = searchTerm,
					SortBy = sortBy,
					SortOrder = sortOrder,
					PageNumber = pageNumber,
					PageSize = pageSize
				};

				var result = await _orderService.GetAllOrdersAsync(filter);

				return Ok(new ApiResponse<PaginationResponse<RentalOrderResponse>>(
					"Lấy danh sách đơn hàng thành công",
					result));
			}
			catch (Exception ex)
			{
				return StatusCode(500, new ApiResponse<object>(
					"Đã xảy ra lỗi khi lấy danh sách đơn hàng",
					new List<string> { ex.Message },
					500));
			}
		}

		/// <summary>
		/// Lấy danh sách trạng thái đơn hàng có sẵn
		/// </summary>
		/// <returns>Danh sách trạng thái</returns>
		[HttpGet("statuses")]
		[ProducesResponseType(typeof(ApiResponse<List<string>>), StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status500InternalServerError)]
		public async Task<IActionResult> GetOrderStatuses()
		{
			try
			{
				var statuses = await _orderService.GetOrderStatusesAsync();

				return Ok(new ApiResponse<List<string>>(
					"Lấy danh sách trạng thái thành công",
					statuses));
			}
			catch (Exception ex)
			{
				return StatusCode(500, new ApiResponse<object>(
					"Đã xảy ra lỗi khi lấy danh sách trạng thái",
					new List<string> { ex.Message },
					500));
			}
		}

		/// <summary>
		/// Tính toán tóm tắt đơn hàng trước khi tạo order
		/// </summary>
		/// <param name="createOrderDto">Thông tin đơn hàng</param>
		/// <returns>Tóm tắt chi phí và thông tin đơn hàng</returns>
		[HttpPost("calculate")]
		[ProducesResponseType(typeof(ApiResponse<RentalOrderSummaryDto>), StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		[ProducesResponseType(StatusCodes.Status500InternalServerError)]
		public async Task<IActionResult> CalculateOrderSummary([FromBody] CreateRentalOrderRequest createOrderDto)
		{
			try
			{
				var summary = await _orderService.CalculateOrderSummaryAsync(createOrderDto);

				return Ok(new ApiResponse<RentalOrderSummaryDto>(
					"Tính toán đơn hàng thành công",
					summary));
			}
			catch (Exception ex)
			{
				return StatusCode(500, new ApiResponse<object>(
					"Đã xảy ra lỗi khi tính toán đơn hàng",
					new List<string> { ex.Message },
					500));
			}
		}

		/// <summary>
		/// Tạo đơn thuê thiết bị mới
		/// </summary>
		/// <param name="createOrderDto">Thông tin đơn hàng</param>
		/// <returns>Thông tin đơn hàng đã được tạo</returns>
		[HttpPost]
		[ProducesResponseType(typeof(ApiResponse<RentalOrderResponse>), StatusCodes.Status201Created)]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		[ProducesResponseType(StatusCodes.Status500InternalServerError)]
		public async Task<IActionResult> CreateOrder([FromBody] CreateRentalOrderRequest createOrderDto)
		{
			try
			{
				var order = await _orderService.CreateOrderAsync(createOrderDto);

				return CreatedAtAction(
					nameof(GetOrderById),
					new { id = order.OrderId },
					new ApiResponse<RentalOrderResponse>(
						"Tạo đơn hàng thành công",
						order,
						201));
			}
			catch (InvalidOperationException ex)
			{
				return BadRequest(new ApiResponse<object>(
					"Không thể tạo đơn hàng",
					new List<string> { ex.Message },
					400));
			}
			catch (Exception ex)
			{
				return StatusCode(500, new ApiResponse<object>(
					"Đã xảy ra lỗi khi tạo đơn hàng",
					new List<string> { ex.Message },
					500));
			}
		}

		/// <summary>
		/// Lấy thông tin đơn hàng theo ID
		/// </summary>
		/// <param name="id">ID đơn hàng</param>
		/// <returns>Thông tin chi tiết đơn hàng</returns>
		[HttpGet("{id}")]
		[ProducesResponseType(typeof(ApiResponse<RentalOrderResponse>), StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		[ProducesResponseType(StatusCodes.Status500InternalServerError)]
		public async Task<IActionResult> GetOrderById(int id)
		{
			try
			{
				var order = await _orderService.GetOrderByIdAsync(id);

				if (order == null)
				{
					return NotFound(new ApiResponse<object>(
						"Không tìm thấy đơn hàng",
						new List<string> { $"Đơn hàng với ID {id} không tồn tại" },
						404));
				}

				return Ok(new ApiResponse<RentalOrderResponse>(
					"Lấy thông tin đơn hàng thành công",
					order));
			}
			catch (Exception ex)
			{
				return StatusCode(500, new ApiResponse<object>(
					"Đã xảy ra lỗi khi lấy thông tin đơn hàng",
					new List<string> { ex.Message },
					500));
			}
		}

		/// <summary>
		/// Lấy danh sách đơn hàng của người dùng
		/// </summary>
		/// <param name="userId">ID người dùng</param>
		/// <returns>Danh sách đơn hàng</returns>
		[HttpGet("user/{userId}")]
		[ProducesResponseType(typeof(ApiResponse<List<RentalOrderResponse>>), StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status500InternalServerError)]
		public async Task<IActionResult> GetOrdersByUserId(int userId)
		{
			try
			{
				var orders = await _orderService.GetOrdersByUserIdAsync(userId);

				return Ok(new ApiResponse<List<RentalOrderResponse>>(
					"Lấy danh sách đơn hàng thành công",
					orders));
			}
			catch (Exception ex)
			{
				return StatusCode(500, new ApiResponse<object>(
					"Đã xảy ra lỗi khi lấy danh sách đơn hàng",
					new List<string> { ex.Message },
					500));
			}
		}

		/// <summary>
		/// Kiểm tra tính khả dụng của thiết bị
		/// </summary>
		/// <param name="equipmentId">ID thiết bị</param>
		/// <param name="startDate">Ngày bắt đầu thuê</param>
		/// <param name="endDate">Ngày kết thúc thuê</param>
		/// <param name="quantity">Số lượng cần thuê</param>
		/// <returns>Tính khả dụng của thiết bị</returns>
		[HttpGet("check-availability")]
		[ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status400BadRequest)]
		[ProducesResponseType(StatusCodes.Status500InternalServerError)]
		public async Task<IActionResult> CheckAvailability(
			[Required] int equipmentId,
			[Required] DateTime startDate,
			[Required] DateTime endDate,
			int quantity = 1)
		{
			try
			{
				var isAvailable = await _orderService.CheckEquipmentAvailabilityAsync(
					equipmentId, startDate, endDate, quantity);

				return Ok(new ApiResponse<object>(
					"Kiểm tra tính khả dụng thành công",
					new
					{
						EquipmentId = equipmentId,
						IsAvailable = isAvailable,
						Quantity = quantity,
						StartDate = startDate,
						EndDate = endDate
					}));
			}
			catch (Exception ex)
			{
				return StatusCode(500, new ApiResponse<object>(
					"Đã xảy ra lỗi khi kiểm tra tính khả dụng",
					new List<string> { ex.Message },
					500));
			}
		}
	}
}