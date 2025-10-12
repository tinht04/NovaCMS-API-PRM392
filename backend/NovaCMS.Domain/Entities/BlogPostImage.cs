using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class BlogPostImage
{
    public int ImageId { get; set; }

    public int PostId { get; set; }

    public string ImageUrl { get; set; } = null!;

    public bool? IsPrimary { get; set; }

    public int? SortOrder { get; set; }

    public virtual BlogPost Post { get; set; } = null!;
}
