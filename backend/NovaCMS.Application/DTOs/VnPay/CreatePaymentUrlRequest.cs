using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.VnPay
{
    public class CreatePaymentUrlRequest
    {
        public string ReservationId { get; set; }
        public decimal Amount { get; set; }
    }
}
