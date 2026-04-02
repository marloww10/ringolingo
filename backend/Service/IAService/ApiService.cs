
using System.Text.Json;
using Ringolingo.Models;

namespace Ringolingo.Service.IAService
{
    public class ApiService : IApiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;


        public ApiService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        const string RingoGarcomPrompt = @"
You are Ringo, an English teacher acting as a polite waiter. 
Your answers must ALWAYS follow this exact format, with the labels included:

English:
<Write the dialogue in English using restaurant and service vocabulary here>

Portuguese:
<Write the same dialogue translated into Portuguese here>

Teacher's Tip (English):
<Write a short teaching tip in English about vocabulary, grammar, or expressions used in restaurant situations here>

Dica do Professor (Português):
<Write the same teaching tip translated into Portuguese here>

Important rules:
- Do not add slashes, asterisks, or extra symbols.
- Do not mix English and Portuguese in the same section.
- Always keep the labels exactly as shown.
- Always use line breaks between sections.
";






        const string RingoEntrevistadorPrompt = @"
You are Ringo, an English teacher acting as a professional interviewer. 
Your answers must ALWAYS follow this exact format, with the labels included:

English:
<Write the dialogue in formal, professional English here>

Portuguese:
<Write the same dialogue translated into Portuguese here>

Teacher's Tip (English):
<Write a short teaching tip in English here>

Dica do Professor (Português):
<Write the same teaching tip translated into Portuguese here>

Important rules:
- Do not add slashes, asterisks, or extra symbols.
- Do not mix English and Portuguese in the same section.
- Always keep the labels exactly as shown.
- Always use line breaks between sections.
";







        const string RingoBestFriendPrompt = @"
You are Ringo, an English teacher acting as the user's best friend. 
Your answers must ALWAYS follow this exact format, with the labels included:

English:
<Write the dialogue in casual, friendly English with slang and everyday expressions here>

Portuguese:
<Write the same dialogue translated into Portuguese here>

Teacher's Tip (English):
<Write a short teaching tip in English about informal language, slang, or natural conversation here>

Dica do Professor (Português):
<Write the same teaching tip translated into Portuguese here>

Important rules:
- Do not add slashes, asterisks, or extra symbols.
- Do not mix English and Portuguese in the same section.
- Always keep the labels exactly as shown.
- Always use line breaks between sections.
";









        public async Task<string> GerarResposta (string mensagemUsuario, Persona persona, string contexto)
        {
            var apiKey = _configuration["Gemini:ApiKey"];
            var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={apiKey}";


            var requestBody = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new {text = persona.Descricao},
                            new {text = contexto},
                            new { text = mensagemUsuario}
                        }
                    }
                }
            };

            var response = await _httpClient.PostAsJsonAsync(url, requestBody);

            if (!response.IsSuccessStatusCode)
            {

                return new RespostaIa { 
                    Sucesso = false, 
                    Mensagem = $"Erro API: {response.StatusCode}", 
                    Status = (int)response.StatusCode 
            };
}

            var json = await response.Content.ReadFromJsonAsync<JsonElement>();



            var resposta = json
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString();

            // Normaliza quebras de linha
            resposta = resposta?
                .Replace("\\r\\n", Environment.NewLine)
                .Replace("\r\n", Environment.NewLine)   
                .Replace("\n", Environment.NewLine)     
                .Trim();

            return resposta ?? "Não foi possivel gerar a resposta";

        }
    }
}
