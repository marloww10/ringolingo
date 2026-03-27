
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
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
            // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
            builder.Services.AddOpenApi();
            builder.Services.AddSwaggerGen();

            builder.Services.AddScoped<IAuthService, AuthService>();
            builder.Services.AddScoped<ISenhaService, SenhaService>();
            builder.Services.AddScoped<IXpService, XpService>();
            builder.Services.AddScoped<IMissaoService, MissaoService>();
            builder.Services.AddScoped<IConquistaService, ConquistaService>();

            builder.Services.AddHttpClient<IApiService, ApiService>();


            builder.Services.AddDbContext<AppDbContext>(option => option.UseNpgsql(builder.Configuration.GetConnectionString("PostgresSql")));


            builder.Services.AddSwaggerGen(options =>
            {
                options.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
                {
                    Description = "Para a autoriza��o coloque (bearer {token}).",
                    In = ParameterLocation.Header,
                    Name = "Authorization",
                    Type = SecuritySchemeType.ApiKey
                });

                options.OperationFilter<SecurityRequirementsOperationFilter>();

            });

            builder.Services.AddAuthentication(options =>
            {
                // Define o esquema padr�o
                options.DefaultAuthenticateScheme = "Local";
                options.DefaultChallengeScheme = "Local";
            })
            .AddJwtBearer("Local", options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(builder.Configuration.GetSection("AppSettings:Token").Value)),
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

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseAuthentication();

            app.UseAuthorization();

            app.UseStaticFiles();


            app.MapControllers();

            app.Run();
        }
    }
}
