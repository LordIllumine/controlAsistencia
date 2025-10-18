using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassActividadesAsignadasViewModel
    {
        public List<ClassActividadesAsignadas>? listTareas { get; set; }
        public IEnumerable<ArticulosUsuario>? Usuarios { get; set; }
    }

    public class ClassActividadesAsignadas
    {
        [Display(Name = "Id")]
        public int? Id { get; set; }

        [Display(Name = "Tarea")]
        public string? Tarea { get; set; }

        [Display(Name = "Nombre")]
        public string? Nombre { get; set; }

        public string? Apellido { get; set; }

        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }

        [Display(Name = "Estado Tarea")]
        public string? EstadoTarea { get; set; }

        [Display(Name = "Fecha inicio")]
        public DateTime? fechaIniTarea { get; set; }

        [Display(Name = "Fecha fin")]
        public DateTime? fechafinTarea { get; set; }

        [Display(Name = "Id Asignación")]
        public int? IdAsignacion { get; set; }

        [Display(Name = "Fecha Asignación")]
        public DateTime? FechaAsignacion { get; set; }

        [Display(Name = "Estado Asignación")]
        public string? EstadoAsigancion { get; set; }

        [Display(Name = "Id Colaborador")]
        public int? IdColaborador { get; set; }

        [Display(Name = "Nombre Colaborador")]
        public string? NombreColaborador { get; set; }
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
