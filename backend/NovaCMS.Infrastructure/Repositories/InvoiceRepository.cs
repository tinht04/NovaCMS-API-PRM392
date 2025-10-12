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
    public class InvoiceRepository : GenericRepository<Invoice>, IInvoiceRepository
    {
        private readonly NovaCMSDBContext _context;
        public InvoiceRepository(NovaCMSDBContext context) : base(context)
        {
            _context = context;
        }

        public async Task<decimal> GetTotalRevenueAsync(DateTime from, DateTime to)
        {
            var invoices = await _context.Set<Invoice>()
                .Where(i => i.InvoiceDate >= from && i.InvoiceDate <= to)
                .ToListAsync();

            return invoices.Sum(i => i.Amount);
        }

    }
}
