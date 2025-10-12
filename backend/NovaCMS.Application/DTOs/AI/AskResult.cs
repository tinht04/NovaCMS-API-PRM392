using NovaCMS.Application.DTOs.AI.Responses;
using NovaCMS.Domain.RAG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.AI
{
    public class AskResult
    {
        public string Answer { get; set; } = string.Empty;
        public List<ProductResponseDto> ContextProducts { get; set; } = new();
    }
}
