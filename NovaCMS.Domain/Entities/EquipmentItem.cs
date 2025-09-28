using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class EquipmentItem
{
    public int ItemId { get; set; }

    public int EquipmentId { get; set; }

    public string SerialNumber { get; set; } = null!;

    public string? ConditionNote { get; set; }

    public string? Status { get; set; }

    public virtual Equipment Equipment { get; set; } = null!;

    public virtual ICollection<RentalOrderDetail> RentalOrderDetails { get; set; } = new List<RentalOrderDetail>();
}
