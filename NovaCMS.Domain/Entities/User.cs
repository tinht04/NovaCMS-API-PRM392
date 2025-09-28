using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class User
{
    public int UserId { get; set; }

    public string FullName { get; set; } = null!;

    public string? Email { get; set; }

    public string? PasswordHash { get; set; }

    public string? PhoneNumber { get; set; }

    public int LoyaltyPoints { get; set; }

    public string? GoogleId { get; set; }

    public string? AvatarUrl { get; set; }

    public string? Address { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }

    public string? Status { get; set; }

    public int? RoleId { get; set; }

    public virtual ICollection<BlogPost> BlogPosts { get; set; } = new List<BlogPost>();

    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    public virtual ICollection<RentalOrder> RentalOrders { get; set; } = new List<RentalOrder>();

    public virtual Role? Role { get; set; }
}
