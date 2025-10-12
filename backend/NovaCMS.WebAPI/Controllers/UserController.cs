using CloudinaryDotNet;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.User.Request;
using NovaCMS.Application.DTOs.User.Requests;
using NovaCMS.Application.DTOs.User.Responses;
using NovaCMS.Application.Exceptions;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Application.Services;
using System.Security.Claims;

namespace NovaCMS.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        public readonly IUserService _userService;
        public UserController(IUserService userService)
        {
            _userService = userService;
        }
        //READ ME!!!
        //Bên dưới là ví dụ về cách viết API Controller mà có documentation và đọc link bên duới để hiểu thêm về cách viết api documentation
        //https://swagger.io/resources/articles/documenting-apis-with-swagger/

        /// <summary>
        /// Lấy danh sách người dùng
        /// </summary>
        /// <returns>Danh sách người dùng</returns>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<PaginationResponse<UserResponse>>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllUser(int pageNumber = 1, int pageSize = 10)
        {
            var users = await _userService.GetAllUser(pageNumber, pageSize);
            return Ok(new ApiResponse<PaginationResponse<UserResponse>>("Successfully", users, StatusCodes.Status200OK));
        }


        [Authorize]
        [HttpGet("me")]
        public async Task<IActionResult> GetMeAsync()
        {
            var nameIdentifier = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(nameIdentifier, out var userId))
                throw new DomainException(UserErrors.NotFound);
            var response = await _userService.GetMeAsync(userId: userId);
            return Ok(new ApiResponse<UserResponse>("successfully", response, 200));
        }

        [Authorize]
        [HttpPut("avatar")]
        public async Task<IActionResult> UploadAvatarAsync([FromForm] UploadAvatarRequest file)
        {
            var nameIdentifier = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(nameIdentifier, out var userId))
                throw new DomainException(UserErrors.NotFound);

            var url = await _userService.UploadAvatarAsync(userId, file.File);
            return Ok(new ApiResponse<string>("update successfully", url, 204));
        }

        [Authorize]
        [HttpPatch("profile")]
        public async Task<IActionResult> UpdateProfileAsync([FromBody] UpdateProfileRequest request)
        {
            var nameIdentifier = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(nameIdentifier, out var userId))
                throw new DomainException(UserErrors.NotFound);

            await _userService.UpdateProfileAsync(userId, request);
            return NoContent();
        }

        /// <summary>
        /// dành cho nhân viên tạo khách hàng offline (chỉ cần số điện thoại, có thể bổ sung sau).
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        //[Authorize]
        [HttpPost("offline")]
        public async Task<IActionResult> CreateUserAsync([FromBody] CreateUserOfflineRequest request)
        {
            var user = await _userService.CreateOfflineCustomerAsync(request);
            return Ok(new ApiResponse<UserResponse>("Create customer successfully", user, 201));
        }

        [Authorize]
        [HttpGet("invoices")]
        public async Task<IActionResult> GetUserInvoices()
        {
            var nameIdentifier = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(nameIdentifier, out var userId))
                throw new DomainException(UserErrors.NotFound);

            var userWithInvoices = await _userService.GetUserWithInvoicesAsync(userId);
            return Ok(new ApiResponse<UserWithInvoicesResponse>("Successfully", userWithInvoices, 200));
        }

    }
}
