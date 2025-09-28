using AutoMapper;
using Microsoft.Extensions.Configuration;
using NovaCMS.Application.DTOs.Authentication;
using NovaCMS.Application.DTOs.Authentication.Requests;
using NovaCMS.Application.DTOs.Authentication.Responses;
using NovaCMS.Application.DTOs.User.Requests;
using NovaCMS.Application.DTOs.User.Responses;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IJwtTokenGenerator _jwtTokenGenerator;
        public AuthService(IUnitOfWork unitOfWork, IMapper mapper, IJwtTokenGenerator  jwtTokenGenerator)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _jwtTokenGenerator = jwtTokenGenerator;
        }

        public async Task<UserLoginResponse?> ValidateUserAsync(string email, string password)
        {
            var user = await _unitOfWork.Users.GetByEmailAsync(email);
            if (user == null || !VerifyPassword(password, user.PasswordHash)) return null;

            var response = _mapper.Map<UserLoginResponse>(user);
            response.AccessToken = _jwtTokenGenerator.GenerateToken(
                  new ClaimsAccessToken
                 {
                        UserId = user.UserId.ToString(),
                        RoleName = user.Role.RoleName 
                 });
            return response;
        }

        public async Task<UserRegisterResponse?> CreatedAccountAsync(UserRegisterRequest user)
        {

            var userEntity = await _unitOfWork.Users.GetByEmailAsync(user.Email);
            if (userEntity == null)
            {
                userEntity = _mapper.Map<User>(user);
                userEntity.PasswordHash = EncryptPassword(user.PasswordHash);
                var result = await _unitOfWork.Users.AddAsync(userEntity);
                await _unitOfWork.SaveChangesAsync();
                return _mapper.Map<UserRegisterResponse>(result);
            }
            return null;
        }
        public async Task<bool> ChangePassword(int userId, ChangePasswordRequest request)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(userId);
            if (user == null) return false;
            if (!VerifyPassword(request.CurrentPassword, user.PasswordHash))
                return false;
            user.PasswordHash = EncryptPassword(request.NewPassword);
            _unitOfWork.Users.UpdateAsync(user);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public string EncryptPassword(string password) { return BCrypt.Net.BCrypt.HashPassword(password); }
        public bool VerifyPassword(string password, string hashPassword) { return BCrypt.Net.BCrypt.Verify(password, hashPassword) ? true : false; }
    }
}
