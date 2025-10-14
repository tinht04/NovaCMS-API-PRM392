using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Reservation.Response
{
    public class ReservationResponse
    {
        public string ReservationId { get; set; }
        public DateTime ExpiresAt { get; set; }
        public List<int> ReservedItemIds { get; set; } = new();
        public bool IsSuccess { get; set; }
        public string Message { get; set; }
    }
}
