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
	public class OrderDetailRepository : GenericRepository<RentalOrderDetail>, IOrderDetailRepository
	{
		public OrderDetailRepository(NovaCMSDBContext context) : base(context)
		{
		}
	}
}
