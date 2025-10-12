using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs
{
	public class PaginationResponse<T>
	{
		public List<T> Items { get; set; } = new();
		public int TotalPage { get; set; }
		public int PageSize { get; set; }
		public int PageNumber { get; set; }
		public int TotalCount { get; set; }

		public PaginationResponse<T> Paginate(List<T> items, int count, int pageNumber, int pageSize)
		{
			Items = items;
			TotalCount = count;
			PageSize = pageSize;
			PageNumber = pageNumber;
			TotalPage = (int)Math.Ceiling(count / (double)pageSize);
			return this;
		}

	}
}
