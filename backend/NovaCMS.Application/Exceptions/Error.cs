using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Exceptions
{
    public sealed record Error(string Code, string Message, HttpStatusCode HttpStatusCode);
}
