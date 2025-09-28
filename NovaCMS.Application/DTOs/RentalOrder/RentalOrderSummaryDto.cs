using System;
using System.Collections.Generic;

namespace NovaCMS.Application.DTOs.RentalOrder
{
    public class RentalOrderSummaryDto
    {
        public List<OrderItemSummaryDto> Items { get; set; } = new();
        public decimal SubTotal { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal DeliveryFee { get; set; }
        public decimal TotalAmount { get; set; }
        public int TotalDays { get; set; }
        public DateTime EstimatedStartDate { get; set; }
        public DateTime EstimatedEndDate { get; set; }
    }
    
    public class OrderItemSummaryDto
    {
        public int EquipmentId { get; set; }
        public string EquipmentName { get; set; } = string.Empty;
        public string? Brand { get; set; }
        public string? ImageUrl { get; set; }
        public decimal PricePerDay { get; set; }
        public decimal? DepositFee { get; set; }
        public int Quantity { get; set; }
        public int RentalDays { get; set; }
        public decimal ItemTotal { get; set; }
        public bool IsAvailable { get; set; }
        public int AvailableStock { get; set; }
    }
}