using NovaCMS.Domain.RAG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IVectorStore
    {
        Task<List<ProductRagDto>> LoadAllAsync();
        Task UpsertAsync(ProductRagDto product); // Thêm mới hoặc cập nhật
    }
}
