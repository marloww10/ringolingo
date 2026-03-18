using Microsoft.IdentityModel.Tokens;
using Ringolingo.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
namespace Ringolingo.Service.SenhaService
{
  

    public class SenhaService : ISenhaService
    {
        private readonly IConfiguration _configuration;
        public SenhaService(IConfiguration configuration)
        {
            _configuration = configuration;
        }



        public void CriarSenhaHash (string senha, out byte[] SenhaHash, out byte[] SenhaSalt)
        {
            using (var hmac = new HMACSHA512())
            {
                SenhaSalt = hmac.Key;
                SenhaHash = hmac.ComputeHash(System.Text.Encoding.UTF8.GetBytes(senha));
            }
        }

        public bool VerificarSenhaHash (string senha, byte[] SenhaHash, byte[] SenhaSalt)
        {
            using (var hmac = new HMACSHA512 (SenhaSalt))
            {
                var computedHash = hmac.ComputeHash(System.Text.Encoding.UTF8.GetBytes(senha));
                return computedHash.SequenceEqual(SenhaHash);
            }
        }

        public string CriarToken(Usuario usuario)
        {
            List<Claim> claims = new List<Claim>()
            {
                new Claim("UserId", usuario.Id.ToString()),
                new Claim("Premium", usuario.Premium.ToString()),
                new Claim("Email", usuario.Email.ToString()),
                new Claim("Username", usuario.Nome.ToString())
            };

            var key = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(_configuration.GetSection("AppSettings:Token").Value));

            var cred = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
                    claims: claims,
                    expires: DateTime.Now.AddYears(1),
                    signingCredentials: cred
                );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);

            return jwt;
        }
    }

    
}
