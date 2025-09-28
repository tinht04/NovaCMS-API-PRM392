using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.User.Requests
{
    public class UploadAvatarRequest
    {
        public required IFormFile File { get; set; }
    }
}
