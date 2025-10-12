using NovaCMS.Application.DTOs.Authentication.Requests;
using NovaCMS.Application.DTOs.Authentication.Responses;
using NovaCMS.Application.DTOs.User.Requests;
using NovaCMS.Application.DTOs.User.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IServices
{
    public interface IAuthService
    {
        Task<UserLoginResponse?> ValidateUserAsync(string email, string password);
        Task<UserRegisterResponse?> CreatedAccountAsync(UserRegisterRequest user);
        Task<bool> ChangePassword(int userId, ChangePasswordRequest request);
        string EncryptPassword(string password);
        bool VerifyPassword(string password, string passwordHash);
    }
}
