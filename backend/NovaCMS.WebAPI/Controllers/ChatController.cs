using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NovaCMS.API.Common;
using NovaCMS.Application.DTOs.AI;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Services.RAG;

namespace NovaCMS.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly IEquipmentRagService _rag;

        public ChatController(IEquipmentRagService rag) => _rag = rag;

        public record AskRequest(string Question);

        /// <summary>
        /// Gửi câu hỏi tới hệ thống RAG (Retrieval-Augmented Generation).
        /// Hệ thống sẽ:
        /// 1. Chuyển câu hỏi thành embedding.
        /// 2. Truy vấn VectorStore để tìm sản phẩm liên quan.
        /// 3. Tạo prompt và gọi Gemini API để sinh câu trả lời.
        /// </summary>
        /// <param name="req">
        /// Request body chứa câu hỏi từ người dùng.
        /// Ví dụ:
        /// {
        ///   "question": "Tôi là nghiệp dư thì nên chọn máy nào cho phù hợp?"
        /// }
        /// </param>
        /// <returns>
        /// Kết quả trả về dạng JSON:
        /// {
        ///   "answer": "Chuỗi câu trả lời do AI sinh ra dựa trên dữ liệu sản phẩm."
        /// }
        /// </returns>
        [HttpPost("ask")]
        public async Task<IActionResult> Ask([FromBody] AskRequest req)
        {
            var ans = await _rag.AskAsync(req.Question);
            return Ok(new ApiResponse<AskResult> ( "Response successful", ans,200 ));
        }

        /// <summary>
        /// Lập chỉ mục (index) toàn bộ danh sách thiết bị từ cơ sở dữ liệu
        /// và lưu vào VectorStore (JSON file).
        /// Hàm này chỉ được dùng khi <b>Khởi tạo hệ thống</b>
        /// hoặc khi <b>Deploy trên môi trường mới</b>.
        /// Không nên gọi thường xuyên trong runtime.
        /// </summary>
        /// <remarks>
        /// Khi gọi thành công, hệ thống sẽ quét toàn bộ bảng Equipments,
        /// tạo embedding cho từng sản phẩm, rồi ghi vào file JSON VectorStore.
        /// </remarks>
        /// <returns>
        /// Kết quả trả về dạng JSON:
        /// {
        ///   "message": "Indexed 10 equipments."
        /// }
        /// </returns>
        [HttpPost("index")]
        public async Task<IActionResult> IndexAll()
        {
            var count = await _rag.IndexAllEquipmentsAsync();
            return Ok(new ApiResponse <string> ( "Response successful", $"Indexed {count} equipments.", 200 ));
        }

    }
}
