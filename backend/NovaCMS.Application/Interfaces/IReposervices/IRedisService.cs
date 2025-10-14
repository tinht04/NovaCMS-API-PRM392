using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IRedisService
    {
        Task<T?> GetDataAsync<T>(string key);
        Task SetDataAsync<T>(string key, T value, TimeSpan? absoluteExpireTime = null, TimeSpan? unusedExpireTime = null);
        Task RemoveDataAsync(string key);
        Task<bool> ExistsAsync(string key);
    }
}
