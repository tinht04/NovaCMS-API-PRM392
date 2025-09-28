using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class BlogPost
{
    public int PostId { get; set; }

    public string Title { get; set; } = null!;

    public string Content { get; set; } = null!;

    public int AuthorId { get; set; }

    public string? Location { get; set; }

    public decimal PricePerDay { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public string? Status { get; set; }

    public virtual User Author { get; set; } = null!;

    public virtual ICollection<BlogPostImage> BlogPostImages { get; set; } = new List<BlogPostImage>();
}
