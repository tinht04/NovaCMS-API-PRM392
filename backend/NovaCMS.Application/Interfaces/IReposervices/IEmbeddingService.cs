using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IEmbeddingService
    {
        Task<float[]> EmbedAsync(string text);
        Task<string> GenerateAsync(string systemPrompt, string userPrompt);
    }
}
