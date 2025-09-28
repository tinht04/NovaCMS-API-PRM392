using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Responses
{
    public class UserRegisterResponse
    {
        public int UserId { get; set; }
        public  string Email { get; set; }
        public string? FullName { get; set; }
        //public string AccessToken { get; set; } = null!;
        //public string RefreshToken { get; set; } = null!;
        public  int? RoleId { get; set; }
    }
}
