using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Request
{
    public class UpdateProfileRequest
    {

        public string FullName { get; set; } = null!;

        public string? PhoneNumber { get; set; }

        public string? Address { get; set; }

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
