using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using NovaCMS.Application.DTOs.Authentication;
using NovaCMS.Application.Interfaces.IReposervices;
using NovaCMS.Domain.Entities;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
namespace NovaCMS.Infrastructure.Services
{
    public class JwtTokenGeneratorDefault : IJwtTokenGenerator
    {
        private readonly IConfiguration _configuration;
        public JwtTokenGeneratorDefault(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GenerateToken(ClaimsAccessToken user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_configuration["JwtSettings:SecretKey"]!);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Issuer = _configuration["JwtSettings:Issuer"],
                Audience = _configuration["JwtSettings:Audience"],
                Subject = new ClaimsIdentity(new[]
                {
                    //new Claim(ClaimTypes.Name, user.FullName),
                    new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                    new Claim(ClaimTypes.Role, user.RoleName.ToString()),
                    new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
                }),
                Expires = DateTime.UtcNow.AddMinutes(int.Parse(_configuration["JwtSettings:ExpireMinutes"]!)),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}
