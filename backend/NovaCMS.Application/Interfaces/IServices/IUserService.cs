using Microsoft.AspNetCore.Http;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.User.Request;
using NovaCMS.Application.DTOs.User.Requests;
using NovaCMS.Application.DTOs.User.Responses;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
    public interface IUserService
    {
        Task<PaginationResponse<UserResponse>> GetAllUser(int pageNumber = 1, int pageSize = 10);
        Task<UserResponse> GetMeAsync(int userId);
        Task UpdateProfileAsync(int userId, UpdateProfileRequest request);
        Task<string> UploadAvatarAsync(int userId, IFormFile file);
        Task<UserResponse> CreateOfflineCustomerAsync(CreateUserOfflineRequest request);
        Task<UserWithInvoicesResponse> GetUserWithInvoicesAsync(int userId);
    }
}
