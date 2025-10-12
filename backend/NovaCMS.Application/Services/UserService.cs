using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.User.Request;
using NovaCMS.Application.DTOs.User.Requests;
using NovaCMS.Application.DTOs.User.Responses;
using NovaCMS.Application.Exceptions;
using NovaCMS.Application.Interfaces;
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
    public class UserService : IUserService
    {
        public readonly IUnitOfWork _unitOfWork;
        private readonly ICloudinaryService _cloudinaryService;
        private readonly IMapper _mapper;

        public UserService(IUnitOfWork unitOfWork, ICloudinaryService cloudinaryService, IMapper mapper)
        {
           _unitOfWork = unitOfWork;
           _cloudinaryService = cloudinaryService;
           _mapper = mapper;
        }

        //This is a code guide, you must modify after test database in first time successfully
        public async Task<PaginationResponse<UserResponse>> GetAllUser(int pageNumber = 1, int pageSize = 10)
        {
            var query = _unitOfWork.Users.GetAllUser().AsNoTracking(); // giả sử repo có method Query() trả IQueryable<User>

            var count = await query.CountAsync();

            var users = await query
                .OrderBy(u => u.UserId) // hoặc CreatedAt
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PaginationResponse<UserResponse>()
                .Paginate(_mapper.Map<List<UserResponse>>(users), count, pageNumber, pageSize);
        }


        public async Task UpdateProfileAsync(int userId, UpdateProfileRequest request)
        {
            var user = await _unitOfWork.Users.GetByIdAsync(userId)
                ?? throw new DomainException(UserErrors.NotFound);

            user.FullName = request.FullName;
            user.PhoneNumber = request.PhoneNumber;
            user.Address = request.Address;
            user.UpdatedAt = request.UpdatedAt;

            await _unitOfWork.SaveChangesAsync();
        }


        public async Task<UserResponse> GetMeAsync(int userId)
        {
            User user = await _unitOfWork.Users.GetByIdAsync(userId) ?? throw new DomainException(UserErrors.NotFound);
            return _mapper.Map<UserResponse>(user);
        }

        public async Task<string> UploadAvatarAsync(int userId, IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new DomainException(UserErrors.NoFileUploaded);

            var user = await _unitOfWork.Users.GetByIdAsync(userId);
            if (user == null)
                throw new DomainException(UserErrors.NotFound);

            var url = await _cloudinaryService.UploadImageAsync(file);
            user.AvatarUrl = url;
            _unitOfWork.Users.UpdateAsync(user);
            await _unitOfWork.SaveChangesAsync();
            return url;
        }

        public async Task<UserResponse> CreateOfflineCustomerAsync(CreateUserOfflineRequest request)
        {
            var user = _mapper.Map<User>(request);
            if(await _unitOfWork.Users.IsPhoneExistsAsync(request.PhoneNumber))
                throw new DomainException(UserErrors.PhoneAlreadyExists);
            await _unitOfWork.Users.AddAsync(user);
            await _unitOfWork.SaveChangesAsync();
            return _mapper.Map<UserResponse>(user);
        }

        public async Task<UserWithInvoicesResponse> GetUserWithInvoicesAsync(int userId)
        {
            var user = await _unitOfWork.Users.GetUserWithInvoices(userId);

            if (user == null)
                throw new DomainException(UserErrors.NotFound);

            return _mapper.Map<UserWithInvoicesResponse>(user);
        }
    }
}
