using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Requests
{
    public class UserRegisterRequest
    {
        public required string FullName { get; set; } = null!;

        public required string Email { get; set; } = null!;

        public required string PasswordHash { get; set; } = null!;

        public int RoleId { get; set; }

    }
}
