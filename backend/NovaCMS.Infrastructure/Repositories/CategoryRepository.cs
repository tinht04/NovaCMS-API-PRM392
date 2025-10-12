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
	public class CategoryRepository : GenericRepository<Category>, ICategoryRepository
	{
		private readonly NovaCMSDBContext _context;
		public CategoryRepository(NovaCMSDBContext context) : base(context)
		{
			_context = context;
		}
	}
}
