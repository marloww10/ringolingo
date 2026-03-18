namespace Ringolingo.Models
{
    public class Response<T>
    {
        public T? Dados {  get; set; }
        public string Mensagem { get; set; }
        public bool status { get; set; } = true;
    }
}
