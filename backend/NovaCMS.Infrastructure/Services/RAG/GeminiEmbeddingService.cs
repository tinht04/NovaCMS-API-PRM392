using Microsoft.Extensions.Options;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Infrastructure.Configurations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace NovaCMS.Infrastructure.Services.RAG
{
    public class GeminiEmbeddingService : IEmbeddingService
    {
        private readonly HttpClient _http;
        private readonly GeminiOptions _opt;

        public GeminiEmbeddingService(HttpClient http, IOptions<GeminiOptions> opt)
        {
            _http = http;
            _opt = opt.Value;
        }

        /// <summary>
        /// Gọi Gemini Embedding API để tạo vector từ text
        /// </summary>
        public async Task<float[]> EmbedAsync(string text)
        {
            var url = $"https://generativelanguage.googleapis.com/v1beta/models/{_opt.EmbeddingModel}:embedContent?key={_opt.ApiKey}";

            var body = new
            {
                model = $"models/{_opt.EmbeddingModel}",
                content = new
                {
                    parts = new[]
                    {
                        new { text }
                    }
                },
                taskType = "SEMANTIC_SIMILARITY",
                //generationConfig = new { outputDimensionality = _opt.EmbeddingDimension }
            };

            var req = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json")
            };

            var res = await _http.SendAsync(req);
            var raw = await res.Content.ReadAsStringAsync();

            if (!res.IsSuccessStatusCode)
            {
                throw new Exception($"Gemini embedding failed: {res.StatusCode} - {raw}");
            }

            var root = JsonDocument.Parse(raw).RootElement;

            // Parse response linh hoạt (có thể là object hoặc array)
            if (root.TryGetProperty("embedding", out var emb))
            {
                if (emb.ValueKind == JsonValueKind.Object && emb.TryGetProperty("values", out var values))
                {
                    return values.EnumerateArray().Select(x => (float)x.GetDouble()).ToArray();
                }
                else if (emb.ValueKind == JsonValueKind.Array && emb[0].TryGetProperty("values", out var arrValues))
                {
                    return arrValues.EnumerateArray().Select(x => (float)x.GetDouble()).ToArray();
                }
            }

            throw new Exception("Unexpected embedding response: " + raw);
        }

        /// <summary>
        /// Gọi Gemini Generate API để sinh text từ systemPrompt + userPrompt
        /// </summary>
        public async Task<string> GenerateAsync(string systemPrompt, string userPrompt)
        {
            var url = $"https://generativelanguage.googleapis.com/v1beta/models/{_opt.GenModel}:generateContent?key={_opt.ApiKey}";

            var body = new
            {
                contents = new[]
                {
                    new
                    {
                        role = "user",
                        parts = new[] { new { text = userPrompt } }
                    }
                },
                systemInstruction = new
                {
                    role = "system",
                    parts = new[] { new { text = systemPrompt } }
                }
            };

            var req = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json")
            };

            var res = await _http.SendAsync(req);
            var raw = await res.Content.ReadAsStringAsync();

            if (!res.IsSuccessStatusCode)
            {
                throw new Exception($"Gemini generate failed: {res.StatusCode} - {raw}");
            }

            var doc = JsonDocument.Parse(raw);

            return doc.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString() ?? "";
        }
    }
}