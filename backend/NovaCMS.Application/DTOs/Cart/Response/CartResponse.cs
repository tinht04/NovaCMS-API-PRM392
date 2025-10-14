using NovaCMS.Application.DTOs.Cart.Request;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Cart.Response
{
    public class CartResponse
    {
        public string UserId { get; set; }
        public List<CartItemRequest> Items { get; set; } = new();
    }
}
