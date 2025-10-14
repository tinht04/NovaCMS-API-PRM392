using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using NovaCMS.Application.Interfaces.IReposervices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Infrastructure.Services
{
    public class RedisService : IRedisService
    {
        private readonly IDistributedCache _cache;

        // Nhận IDistributedCache đã được đăng ký ở Program.cs
        public RedisService(IDistributedCache cache)
        {
            _cache = cache;
        }

        public async Task<T?> GetDataAsync<T>(string key)
        {
            var jsonData = await _cache.GetStringAsync(key);

            if (jsonData is null)
            {
                return default(T); // Hoặc default
            }

            // Deserialize từ JSON về lại object
            return JsonConvert.DeserializeObject<T>(jsonData);
        }

        public async Task SetDataAsync<T>(string key, T value, TimeSpan? absoluteExpireTime = null, TimeSpan? unusedExpireTime = null)
        {
            var options = new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = absoluteExpireTime, // Mặc định cache 1 giờ
                SlidingExpiration = unusedExpireTime
            };

            // Serialize object thành chuỗi JSON để lưu
            var jsonData = JsonConvert.SerializeObject(value);
            await (_cache.SetStringAsync(key, jsonData, options) ?? Task.CompletedTask);
        }

        public async Task RemoveDataAsync(string key)
        {
            await _cache.RemoveAsync(key);
        }
        public async Task<bool> ExistsAsync(string key)
        {
            var data = await _cache.GetAsync(key);
            return data != null;
        }
    }
}
