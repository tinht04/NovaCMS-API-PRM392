using NovaCMS.Application.DTOs.Dashboard.Response;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Services
{
    public class DashboardService: IDashboardService
    {
        private readonly IUnitOfWork _uow;

        public DashboardService(IUnitOfWork uow)
        {
            _uow = uow;
        }

        public async Task<DashboardSummaryResponse> GetSummaryAsync()
        {
            var now = DateTime.UtcNow;
            var startOfMonth = new DateTime(now.Year, now.Month, 1);
            var endOfMonth = startOfMonth.AddMonths(1).AddTicks(-1);

            return new DashboardSummaryResponse
            {
                TotalRevenue = await _uow.Invoices.GetTotalRevenueAsync(startOfMonth, endOfMonth),
                ActiveRentals = await _uow.RentalOrderDetails.GetActiveRentalsAsync(),
                AvailableEquipments = await _uow.EquipmentItems.GetAvailableEquipmentsAsync(),
                NewCustomers = await _uow.Users.GetNewCustomersAsync(startOfMonth, endOfMonth)
            };
        }

        public async Task<List<UpcomingRentalResponse>> GetUpcomingRentalsAsync()
        {
            var now = DateTime.UtcNow;
            var nextWeek = now.AddDays(7);

            var rentals = await _uow.RentalOrderDetails.GetUpcomingRentalsAsync(now, nextWeek);

            return rentals.Select(d => new UpcomingRentalResponse
            {
                OrderId = d.OrderId,
                CustomerName = d.Order?.User?.FullName ?? "Unknown",
                EquipmentId = d.Equipment.EquipmentId,
                EquipmentName = d.Equipment?.Name ?? "Unknown",
                EquipmentImage = d.Equipment?.EquipmentImages.FirstOrDefault()?.ImageUrl ?? string.Empty,
                RentalStartDate = d.RentalStartDate,
                RentalEndDate = d.RentalEndDate,
                Status = d.Order?.Status ?? "Unknown"
            }).ToList();
        }
    }
}
