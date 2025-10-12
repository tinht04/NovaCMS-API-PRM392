using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Infrastructure.Configurations
{
    public class GeminiOptions
    {
        public string ApiKey { get; set; } = default!;
        public string GenModel { get; set; } = "gemini-2.5-flash";
        public string EmbeddingModel { get; set; } = "gemini-embedding-001";
        public int EmbeddingDimension { get; set; } = 768;
    }
}
