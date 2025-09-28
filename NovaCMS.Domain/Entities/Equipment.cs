using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class Equipment
{
    public int EquipmentId { get; set; }

    public int? CategoryId { get; set; }

    public string Name { get; set; } = null!;

    public string? Brand { get; set; }

    public string? Description { get; set; }

    public string? ConditionNote { get; set; }

    public decimal PricePerDay { get; set; }

    public decimal? DepositFee { get; set; }

    public string? Status { get; set; }

    public int? Stock { get; set; }

    public virtual Category? Category { get; set; }

    public virtual ICollection<EquipmentImage> EquipmentImages { get; set; } = new List<EquipmentImage>();

    public virtual ICollection<EquipmentItem> EquipmentItems { get; set; } = new List<EquipmentItem>();

    public virtual ICollection<RentalOrderDetail> RentalOrderDetails { get; set; } = new List<RentalOrderDetail>();
}
