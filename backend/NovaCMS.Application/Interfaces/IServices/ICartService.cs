using NovaCMS.Application.DTOs.Cart.Request;
using NovaCMS.Application.DTOs.Cart.Response;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
    public interface ICartService
    {
        Task<CartResponse> GetCartAsync(string userId);
        Task<CartResponse> AddItemToCartAsync(string userId, CartItemRequest item);
    }
}
