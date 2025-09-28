using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class Invoice
{
    public int InvoiceId { get; set; }

    public int OrderId { get; set; }

    public DateTime? InvoiceDate { get; set; }

    public decimal Amount { get; set; }

    public int? CreatedByStaffId { get; set; }

    public DateTime? DueDate { get; set; }

    public string? PaymentMethod { get; set; }

    public string? PaymentStatus { get; set; }

    public virtual User? CreatedByStaff { get; set; }

    public virtual RentalOrder Order { get; set; } = null!;
}
