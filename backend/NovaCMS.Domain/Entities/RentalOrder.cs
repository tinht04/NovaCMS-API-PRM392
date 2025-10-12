using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class RentalOrder
{
    public int OrderId { get; set; }

    public int UserId { get; set; }

    public DateTime? OrderDate { get; set; }

    public string? ReferenceNo { get; set; }

    public string? Note { get; set; }

    public decimal TotalAmount { get; set; }

    public string? Status { get; set; }

    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    public virtual ICollection<RentalOrderDetail> RentalOrderDetails { get; set; } = new List<RentalOrderDetail>();

    public virtual User User { get; set; } = null!;
}
