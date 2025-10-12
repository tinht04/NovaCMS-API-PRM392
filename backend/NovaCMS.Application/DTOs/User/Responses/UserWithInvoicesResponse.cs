using NovaCMS.Application.DTOs.Invoice.Response;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Responses
{
    public class UserWithInvoicesResponse
    {
        public int UserId { get; set; }
        public string FullName { get; set; } = null!;
        public string? Email { get; set; }
        public string? PhoneNumber { get; set; }
        public string? RoleName { get; set; }

        public List<InvoiceResponse> Invoices { get; set; } = new();
    }
}
