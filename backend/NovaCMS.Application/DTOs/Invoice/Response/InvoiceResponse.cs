using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Invoice.Response
{
    public class InvoiceResponse
    {
        public int InvoiceId { get; set; }
        public DateTime? InvoiceDate { get; set; }
        public decimal Amount { get; set; }
        public DateTime? DueDate { get; set; }
        public string? PaymentMethod { get; set; }
        public string? PaymentStatus { get; set; }
    }
}
