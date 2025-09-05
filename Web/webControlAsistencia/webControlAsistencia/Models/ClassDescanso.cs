using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassDescanso
    {
        [Display(Name = "Tipo de Descanso")]
        public string? TipoDescanso { get; set; }

        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }
    }
}
