using Microsoft.Extensions.Hosting;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassDescansos
    {
        public class ClassDescanso_Iniciar
        {
            [Required]
            public int idAsignacion { get; set; }
            [Required]
            public string tipoDescanso { get; set; }
            [Required]
            public DateTime horaInicio { get; set; }
            public int? idDescanso { get; set; } = null;
            public string? mensaje { get; set; } = null;
        }
        public class ClassDescanso_Finalizar
        {
            [Required]
            public int idDescanso { get; set; }
            [Required]
            public DateTime horaFin { get; set; }
            public string? mensaje { get; set; } = null;
        }
        public class ClassDescanso_Resumen
        {
            [Required]
            public int idColaborador { get; set; }
            [Required]
            public DateTime desde { get; set; }
            [Required]
            public DateTime hasta { get; set; }
        }
        public class ClassDescanso_ResumenResp
        {
            public int idColaborador { get; set; }
            public int minutosDescanso { get; set; }
        }
    }

   
}
