using AutoMapper;
using NovaCMS.Application.DTOs;
using NovaCMS.Application.DTOs.Equipment;
using NovaCMS.Application.DTOs.Equipment.Responses;
using NovaCMS.Application.DTOs.EquipmentImage.Responses;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Services
{
	public class EquipmentService : IEquipmentService
	{
		private readonly IUnitOfWork _unitOfWork;
		private readonly IMapper _mapper;

		public EquipmentService(IUnitOfWork unitOfWork, IMapper mapper)
		{
			_unitOfWork = unitOfWork;
			_mapper = mapper;
		}

		public async Task<List<string>> GetAvailableBrandsAsync()
		{
			return await _unitOfWork.Equipments.GetAvailableBrandsAsync();
		}

		public async Task<EquipmentResponse?> GetEquipmentByIdAsync(int id)
		{
			var equipment = await _unitOfWork.Equipments.GetEquipmentByIdAsync(id);

			if (equipment == null)
				return null;
            var trueAvailableStock = await _unitOfWork.EquipmentItems.GetAvailableStockAsync(
                    equipment.EquipmentId,
                    DateTime.UtcNow, // Hoặc một khoảng thời gian mặc định
                    DateTime.UtcNow.AddDays(1)
                );

            // Cập nhật lại trạng thái
            equipment.Stock = trueAvailableStock;
            equipment.Status = trueAvailableStock > 0 ? "Còn hàng" : "Hết hàng";
            var response = _mapper.Map<EquipmentResponse>(equipment);
			var imageResponses = _mapper.Map<List<EquipmentImageResponse>>(equipment.EquipmentImages);
			response.imageResponses = imageResponses;

			return response;
		}

		public async Task<PaginationResponse<EquipmentResponse>> GetFilteredEquipmentAsync(EquipmentFilterDto filter)
		{
			// Lấy dữ liệu từ repository với pagination
			var (equipmentList, totalCount) = await _unitOfWork.Equipments.GetFilteredEquipmentAsync(filter);

			// Map Equipment entities sang EquipmentResponse DTOs sử dụng AutoMapper
			var equipmentResponses = _mapper.Map<List<EquipmentResponse>>(equipmentList);

            foreach (var equipment in equipmentResponses)
            {
                // Lấy số lượng thực tế có sẵn, đã trừ đi số lượng bị giữ trong Redis
                var trueAvailableStock = await _unitOfWork.EquipmentItems.GetAvailableStockAsync(
                    equipment.EquipmentId,
                    DateTime.UtcNow, // Hoặc một khoảng thời gian mặc định
                    DateTime.UtcNow.AddDays(1)
                );

                // Cập nhật lại trạng thái
                equipment.Stock = trueAvailableStock;
				equipment.Status = trueAvailableStock > 0 ? "Còn hàng" : "Hết hàng";
                equipment.IsAvailable = trueAvailableStock > 0;
            }

            // Tạo pagination response
            var paginationResponse = new PaginationResponse<EquipmentResponse>();
			return paginationResponse.Paginate(equipmentResponses, totalCount, filter.PageNumber, filter.PageSize);
		}

		public async Task<(decimal MinPrice, decimal MaxPrice)> GetPriceRangeAsync()
		{
			return await _unitOfWork.Equipments.GetPriceRangeAsync();
		}

		public async Task<List<EquipmentResponse>> GetRelatedEquipmentsAsync(int id, int categoryId)
		{
			var list = await _unitOfWork.Equipments.GetRelatedEquipmentsAsync(id, categoryId);
			return _mapper.Map<List<EquipmentResponse>>(list);
		}
	}
}