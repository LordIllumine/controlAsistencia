using System.Text.Json.Serialization;
using System.ComponentModel.DataAnnotations;

namespace ApiControlTiempo.Class
{
    public class ClassControlAsistencia
    {
        [Required]
        public int idRegistro { get; set; }

        [Required]
        public string horaEntrada { get; set; }

        [Required]
        public string horaSalida { get; set; }

        [Required]
        public string mensaje { get; set; }
    }

    public class ClassControlAsistenciaGetByRango
    {
        [Required]
        public int idColaborador { get; set; }
        [Required]
        public DateOnly? desde { get; set; }
        [Required]
        public DateOnly? hasta { get; set; }
    }

    public class ClassControlAsistenciaResp
    {
        public int idRegistro { get; set; }
        public int idColaborador { get; set; }
        public DateOnly? fecha { get; set; }
        public TimeSpan? horaEntrada { get; set; }  // NULLABLE
        public string IPREGISTRO { get; set; }   // NULLABLE
        public string MACADDRESS { get; set; }
        public DateTime? fecha_Creacion { get; set; }
        public DateTime? fecha_Actualizacion { get; set; }
    }

    public class ClassAsistenciaHoras
    {
        [Required]
        public int idColaborador { get; set; }
        [Required]
        public int minutosTrabajados { get; set; }
    }

    public class ClassAsistenciaMarcarEntrada
    {
        [Required]
        public int idColaborador { get; set; }
        //[Required]
        //public DateTime fecha { get; set; }
        //[Required]
        //public string horaEntrada { get; set; }
        [Required]
        public string ip { get; set; }
        [Required]
        public string mac { get; set; }
        public string? mensaje { get; set; } = null;
    }

    public class ClassAsistenciaMarcarSalida
    {
        [Required]
        public int idColaborador { get; set; }
        //[Required]
        //public DateTime fecha { get; set; }
        //[Required]
        //public string horaSalida { get; set; }
        public string? mensaje { get; set; } = null;
    }

    
}
