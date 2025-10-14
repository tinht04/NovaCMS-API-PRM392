using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Logging;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Infrastructure.Data;


namespace NovaCMS.Infrastructure.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {

        private readonly NovaCMSDBContext _context;
        private IDbContextTransaction? _transaction;
        private readonly ILogger<UnitOfWork> _logger;

        public UnitOfWork(
            NovaCMSDBContext context,
            ILogger<UnitOfWork> logger,
            IUserRepository users,
            IEquipmentRepository equipments,
            IEquipmentItemRepository equipmentItems,
            ICategoryRepository categories,
            IOrderRepository orders,
            IOrderDetailRepository orderDetails,
            IInvoiceRepository invoices,
            IRentalOrderDetailRepository rentalOrderDetails)
        {
            _context = context;
            _logger = logger;

            Users = users;
            Equipments = equipments;
            EquipmentItems = equipmentItems;
            Categories = categories;
            Orders = orders;
            OrderDetails = orderDetails;
            Invoices = invoices;
            RentalOrderDetails = rentalOrderDetails;
        }

        public IUserRepository Users { get; }
        public IEquipmentRepository Equipments { get; }
        public IEquipmentItemRepository EquipmentItems { get; }
        public ICategoryRepository Categories { get; }
        public IOrderRepository Orders { get; }
        public IOrderDetailRepository OrderDetails { get; }
        public IInvoiceRepository Invoices { get; }
        public IRentalOrderDetailRepository RentalOrderDetails { get; }

        public async Task<int> SaveChangesAsync() => await _context.SaveChangesAsync();

        public async Task BeginTransactionAsync()
        {
            if (_transaction != null)
                return;

            _transaction = await _context.Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            try
            {
                await _context.SaveChangesAsync();
                _transaction?.Commit();
            }
            catch
            {
                await RollbackTransactionAsync();
                throw;
            }
            finally
            {
                if (_transaction != null)
                {
                    await _transaction.DisposeAsync();
                    _transaction = null;
                }
            }
        }

        public async Task RollbackTransactionAsync()
        {
            if (_transaction != null)
            {
                await _transaction.RollbackAsync();
                await _transaction.DisposeAsync();
                _transaction = null;
            }
        }

        public Task<ITransaction?> GetCurrentTransactionAsync()
        {
            if (_transaction == null)
                return Task.FromResult<ITransaction?>(null);

            return Task.FromResult<ITransaction?>(new EfTransaction(_transaction));
        }
    }
}
