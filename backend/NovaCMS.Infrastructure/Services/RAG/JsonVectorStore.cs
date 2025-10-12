using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Domain.RAG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace NovaCMS.Infrastructure.Services.RAG
{
    public class JsonVectorStore : IVectorStore
    {
        private readonly string _filePath = "products_embeddings.json";
        private readonly SemaphoreSlim _lock = new(1, 1);

        public async Task<List<ProductRagDto>> LoadAllAsync()
        {
            if (!File.Exists(_filePath)) return new List<ProductRagDto>();
            var json = await File.ReadAllTextAsync(_filePath);
            return JsonSerializer.Deserialize<List<ProductRagDto>>(json) ?? new List<ProductRagDto>();
        }

        public async Task UpsertAsync(ProductRagDto product)
        {
            await _lock.WaitAsync();
            try
            {
                var all = await LoadAllAsync();
                var existing = all.FirstOrDefault(p => p.EquipmentId == product.EquipmentId);
                if (existing != null) all.Remove(existing); // update
                all.Add(product);

                var json = JsonSerializer.Serialize(all, new JsonSerializerOptions { WriteIndented = true });
                await File.WriteAllTextAsync(_filePath, json);
            }
            finally
            {
                _lock.Release();
            }
        }
    }
}
