using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassActividadesAsignadasViewModel
    {
        public List<ClassActividadesAsignadas>? ActividadesAsig { get; set; }
        public IEnumerable<ArticulosUsuario>? Usuarios { get; set; }
    }

    public class ClassActividadesAsignadas
    {
        [Display(Name = "Id")]
        public int? Id { get; set; }

        [Display(Name = "Tarea")]
        public string? Tarea { get; set; }

        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }

        [Display(Name = "Fecha inicio")]
        public DateTime? FechaInicio { get; set; }
        [Display(Name = "Fecha fin")]
        public DateTime? FechaFin { get; set; }
    }

    public class ArticulosUsuario
    {
        public int? Identifiacion_Usuario { get; set; }
        public string? Rol_usuario { get; set; }
    }

    public class Respuesta_Mensaje
    {
        public string? Mensaje { get; set; }
    }
}
