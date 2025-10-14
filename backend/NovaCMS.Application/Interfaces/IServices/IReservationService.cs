using NovaCMS.Application.DTOs.Reservation.Request;
using NovaCMS.Application.DTOs.Reservation.Response;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
    public interface IReservationService
    {
        Task<ReservationResponse> CreateReservationAsync(string userId, ReservationRequest request);
    }
}
