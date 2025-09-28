using System;
using System.Collections.Generic;

namespace NovaCMS.Domain.Entities;

public partial class EquipmentImage
{
    public int ImageId { get; set; }

    public int EquipmentId { get; set; }

    public string ImageUrl { get; set; } = null!;

    public bool? IsPrimary { get; set; }

    public int? SortOrder { get; set; }

    public virtual Equipment Equipment { get; set; } = null!;
}
