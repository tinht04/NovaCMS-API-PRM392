using NovaCMS.Application.DTOs.Authentication;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IJwtTokenGenerator
    {
        string GenerateToken(ClaimsAccessToken user);
    }
}
