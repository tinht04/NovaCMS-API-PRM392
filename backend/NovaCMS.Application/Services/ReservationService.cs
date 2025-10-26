using NovaCMS.Application.DTOs.Reservation.Request;
using NovaCMS.Application.DTOs.Reservation.Response;
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
    public class ReservationService : IReservationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRedisService _redisService;
        private const int ReservationMinutes = 15;

        public ReservationService(IUnitOfWork unitOfWork, IRedisService redisService)
        {
            _unitOfWork = unitOfWork;
            _redisService = redisService;
        }

        public async Task<ReservationResponse> CreateReservationAsync(string userId, ReservationRequest request)
        {
            var reservationId = Guid.NewGuid().ToString();
            var allAvailableItems = new List<EquipmentItem>();
            decimal totalAmount = 0;
            // BƯỚC 1: KIỂM TRA TỒN KHO VÀ THU THẬP TẤT CẢ SẢN PHẨM CÓ THỂ GIỮ, ĐỒNG THỜI TÍNH TỔNG TIỀN
            foreach (var item in request.Items)
            {
                var availableItems = await _unitOfWork.EquipmentItems.GetAvailableItemsAsync(
                    item.EquipmentId, item.RentalStartDate, item.RentalEndDate, item.Quantity);

                if (availableItems.Count < item.Quantity)
                {
                    // Nếu một sản phẩm không đủ, hủy ngay lập tức
                    return new ReservationResponse { IsSuccess = false, Message = $"The equipment ID {item.EquipmentId} is not sufficient in quantity." };
                }
                //Add từng sản phẩm vào danh sách giữ chỗ nè
                allAvailableItems.AddRange(availableItems);

                // Tính tiền cho từng item
                var equipment = await _unitOfWork.Equipments.GetByIdAsync(item.EquipmentId);
                if (equipment != null)
                {
                    var days = (decimal)(item.RentalEndDate.Date - item.RentalStartDate.Date).TotalDays;
                    if (days < 1) days = 1;
                    totalAmount += equipment.PricePerDay * item.Quantity * days;
                }
            }

            try
            {
                // BƯỚC 2: TẠO PHIẾU GIỮ CHỖ VÀ LƯU VÀO REDIS (CHỈ 1 LẦN)
                var reservedItemIds = allAvailableItems.Select(i => i.ItemId).ToList();
                var reservationDetails = new ReservationDetailResponse
                {
                    UserId = userId,
                    ReservedItemIds = reservedItemIds,
                    OriginalRequestItems = request.Items,
                    // Lưu luôn amount vào reservationDetails để dùng lại khi thanh toán
                    Amount = totalAmount
                };

                // 2.1. Lưu phiếu giữ chỗ tổng hợp
                await _redisService.SetDataAsync(
                    $"reservation:{reservationId}",
                    reservationDetails,
                    absoluteExpireTime: TimeSpan.FromMinutes(ReservationMinutes)
                );

                // 2.2. Khóa từng sản phẩm riêng lẻ
                foreach (var itemId in reservedItemIds)
                {
                    var key = $"reservation:item:{itemId}";
                    await _redisService.SetDataAsync(
                        key,
                        new { ReservationId = reservationId },
                        absoluteExpireTime: TimeSpan.FromMinutes(ReservationMinutes)
                    );
                }

                // BƯỚC 3: TRẢ VỀ KẾT QUẢ THÀNH CÔNG
                return new ReservationResponse
                {
                    IsSuccess = true,
                    ReservationId = reservationId,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(ReservationMinutes),
                    ReservedItemIds = reservedItemIds,
                    Message = "Product will be held 15 minutes.",
                    Amount = totalAmount
                };
            }
            catch (Exception)
            {
                 await _redisService.RemoveDataAsync($"reservation:{reservationId}");
                throw;
            }
        }
    }
}
