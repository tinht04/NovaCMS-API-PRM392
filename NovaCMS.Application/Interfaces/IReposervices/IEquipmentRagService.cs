using NovaCMS.Application.DTOs.AI;
using NovaCMS.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Interfaces.IReposervices
{
    public interface IEquipmentRagService
    {
        Task UpsertEquipmentAsync(Equipment e);
        Task<int> IndexAllEquipmentsAsync();
        Task<AskResult> AskAsync(string question);
    }
}
