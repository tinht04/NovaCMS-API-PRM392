using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IUserRepository : IGenericRepository<User>
    {
        Task<User?> GetByEmailAsync(string email);
        Task<string> GetPasswordExistsAsync(int userId);
        Task<bool> IsPhoneExistsAsync(string phoneNumber);
        Task<int> GetNewCustomersAsync(DateTime from, DateTime to);
        Task<int> GetTotalCustomersAsync();
        Task<User> GetUserWithInvoices(int userId);
    }
}
