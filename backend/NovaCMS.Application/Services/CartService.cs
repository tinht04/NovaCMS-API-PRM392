using NovaCMS.Application.DTOs.Cart.Request;
using NovaCMS.Application.DTOs.Cart.Response;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Services
{
    public class CartService : ICartService
    {
        private readonly IRedisService _redisService;
        private const int CartExpiryDays = 7;
        public CartService(IRedisService redisService)
        {
            _redisService = redisService;
        }

        private string GetCartKey(string userId) => $"cart:{userId}";

        public async Task<CartResponse> GetCartAsync(string userId)
        {
            var cartKey = GetCartKey(userId);
            var cart = await _redisService.GetDataAsync<CartResponse>(cartKey);
            return cart ?? new CartResponse { UserId = userId };
        }

        public async Task<CartResponse> AddItemToCartAsync(string userId, CartItemRequest newItem)
        {
            var cart = await GetCartAsync(userId);

            // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
            var existingItem = cart.Items.FirstOrDefault(i =>
                i.EquipmentId == newItem.EquipmentId &&
                i.RentalStartDate.Date == newItem.RentalStartDate.Date &&
                i.RentalEndDate.Date == newItem.RentalEndDate.Date);

            if (existingItem != null)
            {
                // Nếu đã có, cập nhật số lượng
                existingItem.Quantity += newItem.Quantity;
            }
            else
            {
                // Nếu chưa có, thêm mới
                cart.Items.Add(newItem);
            }

            // Lưu lại giỏ hàng vào Redis với thời gian hết hạn trượt (sliding expiration)
            // Giỏ hàng sẽ bị xóa nếu không được truy cập trong 7 ngày.
            await _redisService.SetDataAsync(
                GetCartKey(userId),
                cart, 
                absoluteExpireTime: TimeSpan.FromDays(CartExpiryDays),
                unusedExpireTime: TimeSpan.FromDays(CartExpiryDays)
            );

            return cart;
        }
    }
}
