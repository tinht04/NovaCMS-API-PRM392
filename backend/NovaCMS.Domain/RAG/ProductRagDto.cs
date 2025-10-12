using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Domain.RAG
{
    public class ProductRagDto
    {
        public int EquipmentId { get; set; }
        public string Name { get; set; } = "";
        public string? Brand { get; set; }
        public string? Description { get; set; }
        public decimal PricePerDay { get; set; }
        public decimal DepositFee { get; set; }
        public int Stock { get; set; }
        public string? Category { get; set; }
        public string? ImageUrl { get; set; }  // optional
        public float[] Vector { get; set; } = Array.Empty<float>();
    }
}
