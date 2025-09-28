using NovaCMS.Application.DTOs.AI;
using NovaCMS.Application.DTOs.AI.Responses;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Domain.Entities;
using NovaCMS.Domain.RAG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Services.RAG
{
    public class EquipmentRagService : IEquipmentRagService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IEmbeddingService _emb;
        private readonly IVectorStore _store;

        public EquipmentRagService(IUnitOfWork unitOfWork, IEmbeddingService emb, IVectorStore store)
        {
            _unitOfWork = unitOfWork;
            _emb = emb; 
            _store = store;
        }

        // Upsert 1 thiết bị (khi thêm mới hoặc cập nhật)
        public async Task UpsertEquipmentAsync(Equipment e)
        {
            var text = $"{e.Name}, {e.Brand}, {e.Description}, Giá={e.PricePerDay}, " +
                       $"Cọc={e.DepositFee}, Stock={e.Stock}, Danh mục={e.Category?.CategoryName}";

            var vec = await _emb.EmbedAsync(text);

            var dto = new ProductRagDto
            {
                EquipmentId = e.EquipmentId,
                Name = e.Name,
                Brand = e.Brand,
                Description = e.Description,
                PricePerDay = e.PricePerDay,
                DepositFee = e.DepositFee.Value,
                Stock = e.EquipmentItems?.Count(i => i.Status == "Available") ?? 0,
                Category = e.Category?.CategoryName,
                ImageUrl = e.EquipmentImages?.FirstOrDefault(i => i.IsPrimary.Value)?.ImageUrl,
                Vector = vec
            };

            await _store.UpsertAsync(dto);
        }

        // Index toàn bộ thiết bị (dùng lần đầu hoặc rebuild)
        public async Task<int> IndexAllEquipmentsAsync()
        {
            var equipments = await _unitOfWork.Equipments.GetAllWithRelationsAsync();

            foreach (var e in equipments)
            {
                await UpsertEquipmentAsync(e);
            }

            return equipments.Count;
        }

        /// <summary>
        /// Sử dụng RAG để trả lời câu hỏi của khách hàng.Bằng cách kêt hợp Gemini Embedding, VectorStore và Gemini Text Generation.
        /// </summary>
        /// <param name="question"></param>
        /// <returns></returns>
        public async Task<AskResult> AskAsync(string question)
        {
            var products = await _store.LoadAllAsync();
            if (products.Count == 0)
                return new AskResult { Answer = "Hiện chưa có dữ liệu sản phẩm để trả lời." };

            var qvec = await _emb.EmbedAsync(question);

            var top = products
                .Select(p => (p, Score: CosineSimilarity(p.Vector, qvec)))
                .OrderByDescending(x => x.Score)
                .Take(5)
                .Select(x => x.p)
                .ToList();

            //Lấy ra thông tin cần thiết của sản phẩm để đưa vào context bằng concat string
            var context = string.Join("\n\n", top.Select(p =>
                $"- {p.Name} ({p.Brand}) | Giá {p.PricePerDay}/ngày | Stock={p.Stock} | Danh mục={p.Category}\n" +
                $"  Mô tả: {p.Description}\n" +
                (string.IsNullOrEmpty(p.ImageUrl) ? "" : $"  ImageUrl: {p.ImageUrl}")
            ));

            var systemPrompt = @"
                Bạn là nhân viên tư vấn thiết bị của cửa hàng NovaCMS.

                Nguyên tắc bắt buộc:
                - Chỉ sử dụng dữ liệu sản phẩm trong CONTEXT để trả lời.
                - Nếu không có sản phẩm phù hợp thì trả lời: 'Xin lỗi, hiện chưa có thông tin sản phẩm phù hợp.'
                - Trả lời ngắn gọn, thân thiện, dễ hiểu và bằng tiếng việt.
                - Nếu nhiều lựa chọn, liệt kê rõ: tên, giá thuê/ngày, tình trạng (còn hàng hay hết hàng).
                - Nếu Stock=0 thì phải nói rõ là 'hết hàng'.

                Khi đưa ra gợi ý sản phẩm:
                - Luôn giải thích ngắn gọn lý do tại sao sản phẩm đó phù hợp với nhu cầu của khách (ví dụ: dễ dùng cho người mới, nhỏ gọn phù hợp du lịch, giá rẻ tiết kiệm, quay phim tốt, chống rung tốt, pin lâu...).
                - Nếu khách là người mới (nghiệp dư), ưu tiên gợi ý thiết bị dễ sử dụng, phổ biến.
                - Nếu khách là người chuyên nghiệp, ưu tiên thiết bị cao cấp, nhiều tính năng, chất lượng cao.
                - Nếu khách hỏi thuê ngắn hạn (1–2 ngày), có thể gợi ý thiết bị giá rẻ hoặc dễ mang theo.
                - Nếu khách quan tâm quay video, gợi ý các máy/ống kính có chống rung, quay 4K/60fps hoặc micro đi kèm.
                - Tùy vào ngữ cảnh mà gợi ý thiết bị phù hợp (ví dụ: du lịch, sự kiện, quay vlog, quay phim chuyên nghiệp...).
                - Tuyệt đối không bịa đặt thông tin ngoài CONTEXT.
                ";

            var userPrompt = $@"Khách hàng hỏi: {question} 
                                        CONTEXT: {context}";
            var ans = await _emb.GenerateAsync(systemPrompt, userPrompt);

            // lấy tên sản phẩm từ answer (vd: "Canon EOS R6", "Nikon Z6 II")
            var mentioned = top.Where(p => ans.Contains(p.Name, StringComparison.OrdinalIgnoreCase)).ToList();
            return new AskResult
            {
                Answer = ans,
                ContextProducts = mentioned.Select(p => new ProductResponseDto
                {
                    EquipmentId = p.EquipmentId,
                    Name = p.Name,
                    Brand = p.Brand,
                    Description = p.Description,
                    PricePerDay = p.PricePerDay,
                    DepositFee = p.DepositFee,
                    Stock = p.Stock,
                    Category = p.Category,
                    ImageUrl = p.ImageUrl
                }).ToList()
            };
        }

        /// <summary>
        /// Tính cosine similarity giữa 2 vector để đánh giá mức độ tương đồng.Bằng cách chia tích vô hướng của 2 vector cho tích độ dài của chúng.
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns></returns>

        private static float CosineSimilarity(float[] a, float[] b)
        {
            double dot = 0, na = 0, nb = 0;
            for (int i = 0; i < a.Length; i++)
            {
                dot += a[i] * b[i];
                na += a[i] * a[i];
                nb += b[i] * b[i];
            }
            return (float)(dot / (Math.Sqrt(na) * Math.Sqrt(nb)));
        }
    }
}
