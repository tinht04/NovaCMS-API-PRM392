using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs.Reservation.Request;
using NovaCMS.Application.DTOs.Reservation.Response;
using NovaCMS.Application.Interfaces.IServices;
using Swashbuckle.AspNetCore.Annotations;
using System.Security.Claims;

namespace NovaCMS.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReservationController : ControllerBase
    {
        private readonly IReservationService _reservationService;

        public ReservationController(IReservationService reservationService)
        {
            _reservationService = reservationService;
        }

        /// <summary>
        /// Tạo một yêu cầu giữ chỗ cho các sản phẩm trong giỏ hàng.
        /// </summary>
        /// <remarks>
        /// API này sẽ kiểm tra tình trạng sẵn có và "khóa" tạm thời các sản phẩm trong 15 phút để người dùng tiến hành thanh toán.
        /// </remarks>
        /// <param name="request">Danh sách các sản phẩm cần giữ chỗ.</param>
        /// <returns>Mã giữ chỗ (ReservationId) nếu thành công.</returns>
        [HttpPost()] // Đổi tên route thành 'reserve' để rõ nghĩa hơn
        [ProducesResponseType(typeof(ReservationResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ReservationResponse), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> CreateReservation([FromBody] ReservationRequest request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var result = await _reservationService.CreateReservationAsync(userId, request);

            if (!result.IsSuccess)
            {
                // Trả về lỗi kèm thông điệp rõ ràng (ví dụ: "Sản phẩm hết hàng")
                return BadRequest(result);
            }

            return Ok(new ApiResponse<ReservationResponse>("success", result,200));
        }
    }
}
