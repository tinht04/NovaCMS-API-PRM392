using Microsoft.EntityFrameworkCore;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Domain.Entities;
using NovaCMS.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Infrastructure.Repositories
{
    public class RentalOrderDetailRepository : GenericRepository<RentalOrder>, IRentalOrderDetailRepository
    {
        private readonly NovaCMSDBContext _context;
        public RentalOrderDetailRepository(NovaCMSDBContext context) : base(context)
        {
            _context = context;
        }

        public async Task<int> GetActiveRentalsAsync()
        {
            return await _context.RentalOrders
                .CountAsync(o => o.Status == "Confirmed" || o.Status == "Rented");
        }

        public async Task<List<RentalOrderDetail>> GetUpcomingRentalsAsync(DateTime from, DateTime to)
        {
            return await _context.RentalOrderDetails
                .Include(d => d.Order).ThenInclude(o => o.User)
                .Include(d => d.EquipmentItem)
                .Include(ei => ei.Equipment)
                .Where(d => d.RentalStartDate >= from && d.RentalStartDate <= to)
                .ToListAsync();
        }
    }
}
