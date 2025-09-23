using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassPermisos
    {
       public class ClassPermiso_Solicitar
        {
            [Required]
            public int idColaborador { get; set; }
            [Required]
            public DateTime fechaInicio { get; set; }
            [Required]
            public DateTime fechaFin { get; set; }
            [Required]
            public string motivo { get; set; }
            public int? idPermiso { get; set; } = null;
            public string? mensaje { get; set; } = null;
        }
        public class ClassEditarPermiso_Solicitar
        {
            [Required]
            public int idPermiso { get; set; }
            [Required]
            public string nuevoEstado { get; set; }
            public string? mensaje { get; set; } = null;
        }
        public class ClassPermiso_List
        {
            public int? idColaborador { get; set; } = null;
            public string? estado { get; set; } = null;
            public DateTime? desde { get; set; } = null;
            public DateTime? hasta { get; set; } = null;
        }

        public class ClassPermiso_List_Resp
        {
            public int idPermiso { get; set; }
            public int idColaborador { get; set; }
            public DateTime? fechaSolicitud { get; set; }
            public DateTime? fechaInicio { get; set; }
            public DateTime? fechaFin { get; set; }
            public string Motivo { get; set; }
            public string Estado { get; set; }
            public DateTime? fechaCreacion { get; set; }
            public DateTime? fechaActualizacion { get; set; }
        }
    }
   
}
