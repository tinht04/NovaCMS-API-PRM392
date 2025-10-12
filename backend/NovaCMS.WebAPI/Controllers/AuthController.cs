using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs.Authentication.Requests;
using NovaCMS.Application.DTOs.User.Requests;
using NovaCMS.Application.DTOs.User.Responses;
using NovaCMS.Application.Exceptions;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using System.Security.Claims;

namespace NovaCMS.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IJwtTokenGenerator _jwtService;
        public AuthController(IAuthService authService, IJwtTokenGenerator jwtService)
        {
            _authService = authService;
            _jwtService = jwtService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] UserLoginRequest request)
        {
            if(request == null)
                return BadRequest(new ApiResponse<object>("Invalid login request.", null, 400));
            var user = await _authService.ValidateUserAsync(request.Email, request.Password);
            if (user == null)
            {
                return Unauthorized(new ApiResponse<object>("Invalid email or password.", null, 401));
            }            
            return Ok(new ApiResponse<UserLoginResponse>("Login success fully!", user));
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] UserRegisterRequest request)
        {
            if (request == null)
                return BadRequest(new ApiResponse<object>("Invalid registration request.", null, 400));
            var user = await _authService.CreatedAccountAsync(request);
            if (user == null)
            {
                return BadRequest(new ApiResponse<object>("Account already exists or registration failed.", null, 400));
            }
            return Ok(new ApiResponse<UserRegisterResponse>("Registration success fully!", user));
        }

        [Authorize]
        [HttpPut("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            if (request == null)
                return BadRequest(new ApiResponse<object>("Invalid change password request.", null, 400));

            var nameIdentifier = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(nameIdentifier, out var userId))
                throw new DomainException(UserErrors.NotFound);

            var result = await _authService.ChangePassword(userId, request);
            if (!result)
            {
                return BadRequest(new ApiResponse<object>("Change password failed.", null, 400));
            }
            return Ok(new ApiResponse<object>("Change password successfully!", null));
        }
    }
}
