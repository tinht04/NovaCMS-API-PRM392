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

        public UnitOfWork(NovaCMSDBContext context, ILogger<UnitOfWork> logger)
        {
            _context = context;
            _logger = logger;

            // Repository initialization using Dependency Injection
            Users = new UserRepository(_context);
            Equipments = new EquipmentRepository(_context);
            EquipmentItems = new EquipmentItemRepository(_context);
			Categories = new CategoryRepository(_context);
            Orders = new OrderRepository(_context);
            OrderDetails = new OrderDetailRepository(_context);
            Invoices = new InvoiceRepository(_context);
            RentalOrderDetails = new RentalOrderDetailRepository(_context);
        }


        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }

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
        //This place to start progress dependency injection
        public IUserRepository Users { get; private set; }
        public IEquipmentRepository Equipments { get; private set; }
		public ICategoryRepository Categories { get; private set; }

        public IEquipmentItemRepository EquipmentItems { get; private set; }

        public IOrderRepository Orders { get; private set; }

        public IOrderDetailRepository OrderDetails { get; private set; }

        public IInvoiceRepository Invoices { get; private set; }

        public IRentalOrderDetailRepository RentalOrderDetails { get; private set; }
    }
}
