using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Requests
{
    public class UserLoginRequest
    {
        public required string Email { get; set; } = null!;
        public required string Password { get; set; } = null!;
    }
}
