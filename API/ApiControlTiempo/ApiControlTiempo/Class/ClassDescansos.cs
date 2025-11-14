using Microsoft.Extensions.Hosting;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassDescansos
    {
        public class ClassDescanso_Obj
        {
            [Required]
            public int idColaborador { get; set; }
            public string? tipoDescanso { get; set; } = null;
            public DateTime? fechaInicio { get; set; } = null;
            public DateTime? fechaFin { get; set; } = null;
        }

        public class ClassDescanso_List
        {
            public int idDescanso { get; set; }
            public int idColaborador { get; set; }
            public string? NombreColaborador { get; set; }
            public string? Correo { get; set; }
            public string? Descripcion { get; set; }
            public string? tipoDescanso { get; set; }
            public DateTime? fechaInicio { get; set; }
            public DateTime? fechaFin { get; set; }
            public string? estado { get; set; }
        }

        public class ClassDescanso_Iniciar
        {
            [Required]
            public int idColaborador { get; set; }
            [Required]
            public string tipoDescanso { get; set; }
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
