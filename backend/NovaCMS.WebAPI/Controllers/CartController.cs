using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs.Cart.Request;
using NovaCMS.Application.DTOs.Cart.Response;
using NovaCMS.Application.Interfaces.IServices;
using Swashbuckle.AspNetCore.Annotations;
using System.Security.Claims;

namespace NovaCMS.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CartController : ControllerBase
    {
        private readonly ICartService _cartService;

        public CartController(ICartService cartService)
        {
            _cartService = cartService;
        }

        /// <summary>
        /// Lấy thông tin giỏ hàng hiện tại của người dùng.
        /// </summary>
        /// <returns>Đối tượng giỏ hàng của người dùng.</returns>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<CartResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetCart()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized();
            }
            var cart = await _cartService.GetCartAsync(userId);
            // Sửa lại cú pháp khởi tạo ApiResponse
            return Ok(new ApiResponse<CartResponse>("success", cart, 200));
        }

        /// <summary>
        /// Thêm một sản phẩm vào giỏ hàng.
        /// </summary>
        /// <remarks>
        /// Nếu sản phẩm với ngày thuê đã tồn tại, số lượng sẽ được cộng dồn. Nếu chưa, sản phẩm mới sẽ được thêm vào.
        /// </remarks>
        /// <param name="item">Thông tin sản phẩm cần thêm.</param>
        /// <returns>Giỏ hàng đã được cập nhật.</returns>
        [HttpPost("add")] // Đổi route để tránh trùng lặp
        [ProducesResponseType(typeof(CartResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> AddToCart([FromBody] CartItemRequest item)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized();
            }

            var updatedCart = await _cartService.AddItemToCartAsync(userId, item);
            return Ok(new ApiResponse<CartResponse>("sucess", updatedCart, 200));
        }
    }
}
