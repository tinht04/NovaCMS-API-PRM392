using Microsoft.EntityFrameworkCore;
using NovaCMS.Application.Exceptions;
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
    public class UserRepository : GenericRepository<User>, IUserRepository
    {
        private readonly NovaCMSDBContext _context;
        public UserRepository(NovaCMSDBContext context) : base(context)
        {
            _context = context;
        }

        public override Task<User?> GetByIdAsync(int userId)
        {
            return _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == userId);
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            var list = await _context.Users.Select(u => u.Email).ToListAsync();
            var result = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Email.Equals(email));
            return result;
        }

        public async Task<string> GetPasswordExistsAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            return user?.PasswordHash ?? string.Empty;
        }

        public async Task<bool> IsPhoneExistsAsync(string phoneNumber)
        {
            return await _context.Users.AnyAsync(u => u.PhoneNumber == phoneNumber);
        }

        public async Task<int> GetNewCustomersAsync(DateTime from, DateTime to)
        {
            return await _context.Users
                .CountAsync(u => u.CreatedAt >= from && u.CreatedAt <= to);
        }

        public async Task<int> GetTotalCustomersAsync()
        {
            return await _context.Users.CountAsync();
        }

        public async Task<User> GetUserWithInvoices(int userId)
        {
            var user = await _context.Users
                .Include(u => u.Invoices)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user != null)
            {
                user.Invoices = user.Invoices
                    .OrderByDescending(i => i.InvoiceDate)
                    .ToList();
            }

            return user ?? throw new DomainException(UserErrors.NotFound);
        }

    }
}
