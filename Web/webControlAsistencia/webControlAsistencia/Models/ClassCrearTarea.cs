using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassCrearTarea
    {
        [Display(Name = "Tarea")]
        required
        public string? Tarea { get; set; }

        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }

        [Display(Name = "Fecha y hora inicio")] 
        required
        public DateTime? FechaInicio { get; set; }

        [Display(Name = "Fecha y hora fin")]
        required
        public DateTime? FechaFin { get; set; }
    }

    public class RootResponse
    {
        [JsonProperty("resp")]
        public Resp? Resp { get; set; }

        [JsonProperty("message")]
        public string? Message { get; set; }
    }

    public class Resp
    {
        [JsonProperty("nombre")]
        public string? Nombre { get; set; }

        [JsonProperty("descripcion")]
        public string? Descripcion { get; set; }

        [JsonProperty("fechaInicio")]
        public DateTime? FechaInicio { get; set; }

        [JsonProperty("fechaFin")]
        public DateTime? FechaFin { get; set; }

        [JsonProperty("idTarea")]
        public int? IdTarea { get; set; }

        [JsonProperty("mensaje")]
        public string? Mensaje { get; set; }
    }
}
