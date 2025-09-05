using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassCrearTarea
    {
        public int? Id { get; set; }

        [Display(Name = "Actividad")]
        public string? Actividad { get; set; }

        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }

        [Display(Name = "Fecha y hora inicio")]
        public DateTime? FechaInicio { get; set; }

        [Display(Name = "Fecha y hora fin")]
        public DateTime? FechaFin { get; set; }
    }
}
