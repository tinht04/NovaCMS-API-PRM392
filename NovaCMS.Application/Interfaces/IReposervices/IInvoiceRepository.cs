using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IInvoiceRepository : IGenericRepository<Invoice>
    {
        Task<decimal> GetTotalRevenueAsync(DateTime from, DateTime to);
    }
}
