using AutoMapper;
using NovaCMS.Application.DTOs.Category.Responses;
using NovaCMS.Application.DTOs.Equipment.Responses;
using NovaCMS.Application.DTOs.EquipmentImage.Responses;
using NovaCMS.Application.DTOs.RentalOrder.Requests;
using NovaCMS.Application.DTOs.RentalOrder.Responses;
using NovaCMS.Application.DTOs.User.Request;
using NovaCMS.Application.DTOs.User.Requests;
using NovaCMS.Application.DTOs.User.Responses;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Mappers
{
	public class MappingProfile : Profile
	{
		public MappingProfile()
		{
			// Add your mappings here
			// Example:
			// CreateMap<Source, Destination>();
			CreateMap<Equipment, EquipmentResponse>()
				.ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.CategoryName : null))
				.ForMember(dest => dest.imageResponses, opt => opt.MapFrom(src => src.EquipmentImages))
				.ForMember(dest => dest.IsAvailable, opt => opt.MapFrom(src => src.Stock > 0 && src.Status == "Available"));


			CreateMap<EquipmentImage, EquipmentImageResponse>();

			CreateMap<Category, CategoryResponse>();

            CreateMap<UserRegisterRequest, User>()
            .ForMember(dest => dest.PasswordHash, opt => opt.Ignore());

			CreateMap<User, UserRegisterResponse>();

            CreateMap<User, UserLoginResponse>()
                .ForMember(dest => dest.RoleName, opt => opt.MapFrom(src => src.Role!.RoleName));

            CreateMap<UpdateProfileRequest, User>();

			CreateMap<User, UserResponse>()
				.ForMember(dest => dest.RoleName, opt => opt.MapFrom(src => src.Role!.RoleName));

			// RentalOrder mapping
			CreateMap<RentalOrder, RentalOrderResponse>()
				.ForMember(dest => dest.OrderDetails, opt => opt.MapFrom(src => src.RentalOrderDetails))
				.ForMember(dest => dest.CustomerInfo, opt => opt.MapFrom(src => new CustomerInfoDto
				{
					FullName = src.User.FullName ?? "",
					Email = src.User.Email ?? "",
					PhoneNumber = src.User.PhoneNumber ?? "",
					Address = src.User.Address
				}));

			// RentalOrderDetail mapping
			CreateMap<RentalOrderDetail, RentalOrderDetailResponse>()
				.ForMember(dest => dest.EquipmentName, opt => opt.MapFrom(src => src.EquipmentItem!.Equipment.Name))
				.ForMember(dest => dest.Brand, opt => opt.MapFrom(src => src.EquipmentItem!.Equipment.Brand))
				.ForMember(dest => dest.SerialNumber, opt => opt.MapFrom(src => src.EquipmentItem!.SerialNumber))
				.ForMember(dest => dest.ImageUrl, opt => opt.MapFrom(src =>
					src.EquipmentItem!.Equipment.EquipmentImages.FirstOrDefault(img => img.IsPrimary == true)!.ImageUrl));
		}
	}
}
