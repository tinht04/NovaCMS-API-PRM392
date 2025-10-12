using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IRentalOrderDetailRepository : IGenericRepository<RentalOrder>
    {
        Task<int> GetActiveRentalsAsync();
        Task<List<RentalOrderDetail>> GetUpcomingRentalsAsync(DateTime from, DateTime to);
    }
}
