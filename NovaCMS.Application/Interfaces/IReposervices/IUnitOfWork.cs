using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IUnitOfWork
    {     
        Task<int> SaveChangesAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
        Task<ITransaction?> GetCurrentTransactionAsync();
        
        IUserRepository Users { get; }
        IEquipmentRepository Equipments { get; }
        IEquipmentItemRepository EquipmentItems { get; }
		ICategoryRepository Categories { get; }
        IOrderRepository Orders { get; }
        IOrderDetailRepository OrderDetails { get; }

        IInvoiceRepository Invoices { get; }
        IRentalOrderDetailRepository RentalOrderDetails { get; }
    }
}
