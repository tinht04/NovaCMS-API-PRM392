using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.DTOs.VnPay
{
	public class PaymentInformationModel
	{
		public string OrderType { get; set; } = "other";
		public double Amount { get; set; }
        public string OrderDescription { get; set; }
		public string Name { get; set; }
	}

}
