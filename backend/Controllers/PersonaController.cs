using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models.Dto;

namespace Ringolingo.Controllers
{
    [ApiController]
    [Route("Personas")]
    public class PersonaController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PersonaController(AppDbContext context)
        {
            _context = context;
        }


        [HttpGet]
        public async Task<ActionResult> GetPersonas()
        {
            var personas = await _context.Personas
            .Select(p => new PersonaDto
            {
                Id = p.Id,
                Nome = p.Nome,
                ImagemUrl = p.ImagemUrl,
                NivelNecessario = p.NivelNecessario
            })
            .ToListAsync();

            return Ok(personas);
        }
    }
}