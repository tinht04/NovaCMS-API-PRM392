using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Requests
{
    public class CreateUserOfflineRequest
    {
        public required string FullName { get; set; }
        public required string PhoneNumber { get; set; }
    }
}
