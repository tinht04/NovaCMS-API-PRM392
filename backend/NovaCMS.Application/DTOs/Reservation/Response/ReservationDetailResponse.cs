using NovaCMS.Application.DTOs.Cart.Request;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Reservation.Response
{
    public class ReservationDetailResponse
    {
        public string UserId { get; set; }
        // Danh sách các ID của từng món đồ cụ thể (EquipmentItem.ItemId) đã được giữ
        public List<int> ReservedItemIds { get; set; } = new();
        // Giữ lại thông tin yêu cầu ban đầu để biết ngày thuê
        public List<CartItemRequest> OriginalRequestItems { get; set; } = new();
    }
}
