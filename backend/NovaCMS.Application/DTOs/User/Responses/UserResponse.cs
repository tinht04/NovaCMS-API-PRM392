using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Responses
{
    public class UserResponse
    {
        public string FullName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string PasswordHash { get; set; } = null!;

        public string? PhoneNumber { get; set; }

        public int LoyaltyPoints { get; set; }

        public string? AvatarUrl { get; set; }

        public string? Address { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        public string? Status { get; set; }

        public int InvoiceId { get; set; }

        public decimal InvoiceAmount { get; set; }

        public DateTime? InvoiceDate { get; set; }

        public int Totaltransactions { get; set; }
        public string? RoleName { get; set; }
    }
}
