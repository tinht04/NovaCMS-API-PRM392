using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Exceptions
{
    public class DomainException(Error error) : Exception(error.Message)
    {
        public Error Error { get; } = error;
    }
}
