using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Ringolingo.Data;
using Ringolingo.Service;
using Ringolingo.Service.AuthService;
using Ringolingo.Service.IAService;
using Ringolingo.Service.SenhaService;
using Ringolingo.Service.XpService;
using Swashbuckle.AspNetCore.Filters;
using System.Text;

namespace Ringolingo
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddControllers();
            builder.Services.AddOpenApi();
            builder.Services.AddSwaggerGen();

            builder.Services.AddScoped<IAuthService, AuthService>();
            builder.Services.AddScoped<ISenhaService, SenhaService>();
            builder.Services.AddScoped<IXpService, XpService>();
            builder.Services.AddScoped<IMissaoService, MissaoService>();
            builder.Services.AddScoped<IConquistaService, ConquistaService>();
            builder.Services.AddHttpClient<IApiService, ApiService>();

            // --- CONFIGURAÇÃO DO BANCO DE DADOS (RAILWAY FRIENDLY) ---
            var rawUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
            string connectionString;

            if (!string.IsNullOrEmpty(rawUrl))
            {
                // Converte postgres:// para o formato que o Npgsql entende
                connectionString = ConverterUrlParaConnectionString(rawUrl);
            }
            else
            {
                // Se não achar na nuvem, usa o local do appsettings.json
                connectionString = builder.Configuration.GetConnectionString("PostgresSql");
            }

            builder.Services.AddDbContext<AppDbContext>(options =>
                options.UseNpgsql(connectionString));
            // -------------------------------------------------------

            builder.Services.AddSwaggerGen(options =>
            {
                options.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
                {
                    Description = "Para a autorização coloque (bearer {token}).",
                    In = ParameterLocation.Header,
                    Name = "Authorization",
                    Type = SecuritySchemeType.ApiKey
                });
                options.OperationFilter<SecurityRequirementsOperationFilter>();
            });

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = "Local";
                options.DefaultChallengeScheme = "Local";
            })
            .AddJwtBearer("Local", options =>
            {
                var tokenKey = builder.Configuration.GetSection("AppSettings:Token").Value 
                               ?? Environment.GetEnvironmentVariable("AppSettings__Token");

                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenKey)),
                    ValidateAudience = false,
                    ValidateIssuer = false
                };
            })
            .AddJwtBearer("Supabase", options =>
            {
                options.Authority = "https://reorkwznacmxtfsvpmfv.supabase.co/auth/v1";
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = false,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true
                };
            });

            AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

            var app = builder.Build();

            // CRIAÇÃO AUTOMÁTICA DAS TABELAS NO RAILWAY
            using (var scope = app.Services.CreateScope())
            {
                var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
                // Como deletamos as migrations antigas, o EnsureCreated vai criar o banco do zero no Railway
                db.Database.EnsureCreated(); 
            }

            // Habilita Swagger para todos os ambientes (para você testar na nuvem)
            app.UseSwagger();
            app.UseSwaggerUI();

            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
            }

            app.UseHttpsRedirection();
            app.UseAuthentication();
            app.UseAuthorization();
            app.UseStaticFiles();
            app.MapControllers();

            app.Run();
        }

        // FUNÇÃO PARA TRADUZIR A URL DO RAILWAY
        static string ConverterUrlParaConnectionString(string url)
        {
            var uri = new Uri(url);
            var host = uri.Host;
            var port = uri.Port;
            var database = uri.AbsolutePath.Trim('/');
            var user = uri.UserInfo.Split(':')[0];
            var password = uri.UserInfo.Split(':')[1];

            return $"Host={host};Port={port};Database={database};Username={user};Password={password};SSL Mode=Require;Trust Server Certificate=true";
        }
    }
}