using Autofac;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using NovaCMS.Application.Interfaces;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Application.Mappers;
using NovaCMS.Application.Services;
using NovaCMS.Application.Services.RAG;
using NovaCMS.Infrastructure.Data;
using NovaCMS.Infrastructure.Repositories;
using NovaCMS.Infrastructure.Services;
using NovaCMS.Infrastructure.Services.RAG;


namespace NovaCMS.API.Configurations
{
    public class ServiceRegistration : Module
    {
        private readonly IConfiguration _configuration;

        public ServiceRegistration(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        protected override void Load(ContainerBuilder builder)
        {
            // Register DbContext
            builder.Register(c =>
            {
                var optionsBuilder = new DbContextOptionsBuilder<NovaCMSDBContext>();
                optionsBuilder.UseMySql(
                    _configuration.GetConnectionString("DefaultConnection"),
                    new MySqlServerVersion(new Version(8, 0, 35))
                );
                return new NovaCMSDBContext(optionsBuilder.Options);
            }).InstancePerLifetimeScope();

            // Register repositories
            builder.RegisterType<UserRepository>().As<IUserRepository>().InstancePerLifetimeScope();
            builder.RegisterType<EquipmentRepository>().As<IEquipmentRepository>().InstancePerLifetimeScope();
            builder.RegisterType<EquipmentItemRepository>().As<IEquipmentItemRepository>().InstancePerLifetimeScope();
            builder.RegisterType<CategoryRepository>().As<ICategoryRepository>().InstancePerLifetimeScope();
            builder.RegisterType<OrderRepository>().As<IOrderRepository>().InstancePerLifetimeScope();
            builder.RegisterType<OrderDetailRepository>().As<IOrderDetailRepository>().InstancePerLifetimeScope();
            builder.RegisterType<InvoiceRepository>().As<IInvoiceRepository>().InstancePerLifetimeScope();
            builder.RegisterType<RentalOrderDetailRepository>().As<IRentalOrderDetailRepository>().InstancePerLifetimeScope();

            // Register UnitOfWork
            builder.RegisterType<UnitOfWork>().As<IUnitOfWork>().InstancePerLifetimeScope();
            // Register services           

            builder.RegisterType<UnitOfWork>().As<IUnitOfWork>().InstancePerLifetimeScope();
            builder.RegisterType<UserService>().As<IUserService>().InstancePerLifetimeScope();
            builder.RegisterType<VnPayService>().As<IVnPayService>().InstancePerLifetimeScope();
            builder.RegisterType<EquipmentService>().As<IEquipmentService>().InstancePerLifetimeScope();
            builder.RegisterType<CategoryService>().As<ICategoryService>().InstancePerLifetimeScope();
            builder.RegisterType<JwtTokenGeneratorDefault>().As<IJwtTokenGenerator>().InstancePerLifetimeScope();
            builder.RegisterType<AuthService>().As<IAuthService>().InstancePerLifetimeScope();
            builder.RegisterType<InvoiceRepository>().As<IInvoiceRepository>().InstancePerLifetimeScope();
            builder.RegisterType<DashboardService>().As<IDashboardService>().InstancePerLifetimeScope();
            builder.RegisterType<OrderService>().As<IOrderService>().InstancePerLifetimeScope();
            builder.RegisterType<JsonVectorStore>()
                   .As<IVectorStore>()
                   .SingleInstance(); // JSON store: shared toàn app
            builder.RegisterType<EquipmentRagService>().As<IEquipmentRagService>()
                   .InstancePerLifetimeScope();
            builder.RegisterType<RedisService>().As<IRedisService>().InstancePerLifetimeScope();
            builder.RegisterType<CartService>().As<ICartService>().InstancePerLifetimeScope();
            builder.RegisterType<ReservationService>().As<IReservationService>().InstancePerLifetimeScope();
        }
    }
}
