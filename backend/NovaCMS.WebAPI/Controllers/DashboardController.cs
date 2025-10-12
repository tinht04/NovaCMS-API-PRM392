using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs.Dashboard.Response;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Application.Services;

namespace NovaCMS.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        /// <summary>
        /// Lấy dữ liệu tổng hợp cho dashboard (doanh thu, đơn active, thiết bị available, khách hàng mới)
        /// </summary>
        [HttpGet("summary")]
        public async Task<ActionResult<ApiResponse<DashboardSummaryResponse>>> GetSummary()
        {
            var result = await _dashboardService.GetSummaryAsync();
            return Ok(new ApiResponse<DashboardSummaryResponse>(
                "Lấy dữ liệu dashboard thành công",
                result,
                200
            ));
        }

        /// <summary>
        /// Lấy danh sách đơn thuê sắp tới (7 ngày tới)
        /// </summary>
        [HttpGet("upcoming-rentals")]
        public async Task<ActionResult<ApiResponse<List<UpcomingRentalResponse>>>> GetUpcomingRentals()
        {
            var result = await _dashboardService.GetUpcomingRentalsAsync();
            return Ok(new ApiResponse<List<UpcomingRentalResponse>>(
                "Lấy danh sách đơn thuê sắp tới thành công",
                result,
                200
            ));
        }
    }
}
