using Autofac;
using Autofac.Extensions.DependencyInjection;
using CloudinaryDotNet;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using NovaCMS.API.Configurations;
using NovaCMS.Application.Configurations;
using NovaCMS.Application.Interfaces;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Application.Mappers;
using NovaCMS.Infrastructure.Configurations;
using NovaCMS.Infrastructure.Services;
using NovaCMS.Infrastructure.Services.RAG;
using System.Reflection;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

//READ ME!!!
//In this project all registration of services are in ServiceRegistration.cs


// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
//builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(typeof(MappingProfile).Assembly);


// Use Autofac as the DI container
builder.Host.UseServiceProviderFactory(new AutofacServiceProviderFactory());
builder.Host.ConfigureContainer<ContainerBuilder>(containerBuilder =>
{
    containerBuilder.RegisterModule(new ServiceRegistration(builder.Configuration));
});

#region Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        var key = Encoding.UTF8.GetBytes(builder.Configuration["JwtSettings:SecretKey"]!);

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["JwtSettings:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["JwtSettings:Audience"],
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(key),
            ClockSkew = TimeSpan.Zero
        };
    });
builder.Services.AddAuthorization();
#endregion

#region Swagger
//Add Swagger document with Bearer to Authentication and Authorization
builder.Services.AddSwaggerGen(opt =>
{
    opt.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo { 
        Title = "novacms-api", 
        Version = "v1", 
        Description = "Api document for Nova Camera Management System EXE201" 
    });

    opt.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Please enter token",
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        BearerFormat = "JWT",
        Scheme = "bearer"
    });

    opt.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type=ReferenceType.SecurityScheme,
                                Id="Bearer"
                            }
                        },
                        new string []{}
                    }
                });
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    opt.IncludeXmlComments(xmlPath);
});
#endregion

# region Cors
//Add Cors to FE can call api from BE EXE201 subject
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.WithOrigins("http://localhost:5173") // Allow the frontend's origin EXE project. Please change it!!!
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials()); // If you're using credentials (cookies, Authorization headers, etc.)
});
#endregion

#region Cloudinary
//Add Cloudinary service
var cloudinarySettings = new CloudinarySettings();
builder.Configuration.GetSection("CloudinarySettings").Bind(cloudinarySettings);
var cloudinary = new Cloudinary(new Account(
    cloudinarySettings.CloudName,
    cloudinarySettings.ApiKey,
    cloudinarySettings.ApiSecret
));
// Register Cloudinary as a singleton service

builder.Services.AddSingleton(cloudinary);
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();
#endregion

// Đăng ký Options pattern cho Gemini
builder.Services.Configure<GeminiOptions>(builder.Configuration.GetSection("Gemini"));

// Đăng ký HttpClient cho GeminiEmbeddingService
builder.Services.AddHttpClient<IEmbeddingService, GeminiEmbeddingService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.UseCors(); // Enable CORS

app.MapControllers();

app.Run();
