using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassSolicitarPermisos
    {
        [Display(Name = "Tipo de permiso")]
        public string TipoPermiso { get; set; }

        [Display(Name = "Asunto")]
        public string Asunto { get; set; }

        [Display(Name = "Descripción")]
        public string Descripcion { get; set; }
    }
}
