using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IRefreshTokenService
    {
        Task SaveAsync(string key, string value);
        Task RevokeAsync(string key);
        Task<bool> IsValidAsync(string key);
        Task<string?> GetAsync(string key);
    }
}
