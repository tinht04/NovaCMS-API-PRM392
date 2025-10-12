using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class RentalOrderDetail
{
    public int OrderDetailId { get; set; }

    public int OrderId { get; set; }

    public int EquipmentId { get; set; }

    public int? EquipmentItemId { get; set; }

    public DateTime RentalStartDate { get; set; }

    public DateTime RentalEndDate { get; set; }

    public decimal? OverdueFee { get; set; }

    public int? OverdueDays { get; set; }

    public DateTime? ReturnDate { get; set; }

    public decimal PricePerDay { get; set; }

    public decimal? DepositFee { get; set; }

    public virtual Equipment Equipment { get; set; } = null!;

    public virtual EquipmentItem? EquipmentItem { get; set; }

    public virtual RentalOrder Order { get; set; } = null!;
}
