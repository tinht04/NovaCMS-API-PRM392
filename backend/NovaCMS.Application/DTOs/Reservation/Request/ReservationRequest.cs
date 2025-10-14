using NovaCMS.Application.DTOs.Cart.Request;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Reservation.Request
{
    public class ReservationRequest
    {
        public List<CartItemRequest> Items { get; set; } = new();
    }
}
