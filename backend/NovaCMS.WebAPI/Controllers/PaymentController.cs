using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs.VnPay;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Application.Services;
using NovaCMS.Application.Utils;
using System.Globalization;
using System.Net;
using System.Threading.Tasks;

namespace NovaCMS.API.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class PaymentController : ControllerBase
	{
		private readonly IVnPayService _vnPayService;
		private readonly IOrderService _orderService;
		private readonly IRedisService _redisService;
        public PaymentController(IVnPayService vnPayService, IOrderService orderService, IRedisService redisService)
        {
            _vnPayService = vnPayService;
            _orderService = orderService;
			_redisService = redisService;
        }

        [HttpPost]
		public IActionResult CreatePaymentUrl(CreatePaymentUrlRequest request)
		{
			if (request == null)
			{
				return BadRequest("Invalid payment information.");
			}
            try
			{
                var paymentModel = new PaymentInformationModel
                {
                    Amount = (double)request.Amount,
                    Name = "Thanh toán đơn hàng NovaCMS",
                    // Giấu ReservationId vào mô tả
                    OrderDescription = $"reservationId={request.ReservationId};Thanh toan don hang."
                };

                var paymentUrl = _vnPayService.CreatePaymentUrl(paymentModel, HttpContext);
                return Ok( new ApiResponse<string>("Payment URL created successfully", paymentUrl, 200));
            }
			catch (Exception ex)
			{
				return StatusCode(500, $"An error occurred: {ex.Message}");
			}
		}

		[HttpGet("callback")]
		public async Task<IActionResult> PaymentCallback()
		{
			try
			{
				var response = _vnPayService.PaymentExecute(Request.Query);
                var reservationId = ParseReservationIdFromOrderInfo(response.OrderDescription);
                if (string.IsNullOrEmpty(reservationId))
                {
                    return Redirect("http://localhost:5173/payment-error?code=INVALID_RESERVATION");
                }
               await _orderService.CreateOrderFromReservationAsync(reservationId, response);
                return Redirect($"http://localhost:5173/payment/{response.Success}");
			}
			catch (Exception ex)
			{
				return StatusCode(500, "An error occurred during payment callback.");
			}
		}

        private string? ParseReservationIdFromOrderInfo(string orderInfo)
        {
            if (string.IsNullOrEmpty(orderInfo)) return null;

            // Sử dụng Regex để tìm một chuỗi có dạng GUID theo sau "reservationId="
            // Đây là cách mạnh mẽ và an toàn nhất
            var regex = new System.Text.RegularExpressions.Regex(@"reservationId=([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})");
            var match = regex.Match(orderInfo);

            // Nếu tìm thấy, Group 1 sẽ chứa chính xác ID mà không có tiền tố "reservationId="
            if (match.Success && match.Groups.Count > 1)
            {
                return match.Groups[1].Value;
            }

            return null;
        }
    }
}