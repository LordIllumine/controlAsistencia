using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassReportesyAnaliticaOperativa
    {
        public class ClassReporte_AsistenciaDiaria
        {
            public int idColaborador { get; set; }
            public string nombre { get; set; }
            public string apellido { get; set; }
            public DateTime? fecha { get; set; }
            public TimeSpan? horaEntrada { get; set; }
            public TimeSpan? horaSalida { get; set; }
        }

        public class ClassReporte_HorasTrabajadas
        {
            [Required]
            public DateTime desde { get; set; }
            [Required]
            public DateTime hasta { get; set; }
            [Required]
            public int idColaborador { get; set; }
        }
        public class ClassReporte_HorasTrabajadasResp
        {
            public int idColaborador { get; set; }
            public int minutosBrutos { get; set; }
        }

        public class ClassReporte_Permisos
        {
            [Required]
            public DateTime desde { get; set; }
            [Required]
            public DateTime hasta { get; set; }
            public string? estado { get; set; } = null;
        }

        public class ClassReporte_PermisosResp
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

        public class ClassReporte_Productividad
        {
            [Required]
            public DateTime desde { get; set; }
            [Required]
            public DateTime hasta { get; set; }
            public int? idColaborador { get; set; } = null;
        }

        public class ClassReporte_ProductividadResp
        {
            public int? idColaborador { get; set; } = null;
            public int? minutosTrabajo { get; set; } = null;
            public int? minutosDescanso { get; set; } = null;
            public int? minutosNetos { get; set; } = null;
        }
    }
}
