using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.Dashboard.Response
{
    public class DashboardSummaryResponse
    {
        public decimal TotalRevenue { get; set; }
        public int ActiveRentals { get; set; }
        public int AvailableEquipments { get; set; }
        public int NewCustomers { get; set; }
    }
}
