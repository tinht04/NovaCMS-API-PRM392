using NovaCMS.Application.DTOs.Dashboard.Response;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
    public interface IDashboardService
    {
        Task<DashboardSummaryResponse> GetSummaryAsync();
        Task<List<UpcomingRentalResponse>> GetUpcomingRentalsAsync();
    }
}
