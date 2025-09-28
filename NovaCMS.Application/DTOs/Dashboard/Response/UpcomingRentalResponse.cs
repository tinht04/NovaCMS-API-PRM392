using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Dashboard.Response
{
    public class UpcomingRentalResponse
    {
        public int OrderId { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public string EquipmentName { get; set; } = string.Empty;
        public DateTime RentalStartDate { get; set; }
        public DateTime RentalEndDate { get; set; }
        public string Status { get; set; } = string.Empty;
    }
}
