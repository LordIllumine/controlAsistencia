using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassSolicitarPermisos
    {
        public int? IdColaborador { get; set; }
        public int? IdPermiso { get; set; }

        [Display(Name = "Tipo de permiso")]
        public string? TipoPermiso { get; set; }

        [Display(Name = "Asunto")]
        public string? Asunto { get; set; }

        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }

        [Display(Name = "Fecha Inicio")]
        public DateTime? FechaInicio { get; set; }

        [Display(Name = "Fecha Fin")]
        public DateTime? FechaFin { get; set; }

        [Display(Name = "Estado")]
        public string? Estado { get; set; }

        public List<ClassPermiso_List>? ListPermiso { get; set; }
    }

    public class ClassPermiso_List
    {
        public int IdPermiso { get; set; }
        public int IdColaborador { get; set; }
        public string Nombre { get; set; }
        public string Correo { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Motivo { get; set; }
        public string? Asunto { get; set; }
        public string? Descripcion { get; set; }
        public string Estado { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaActualizacion { get; set; }
    }
    public class ClassPermiso
    {
        public int? idColaborador { get; set; } = null;
        public string? estado { get; set; } = null;
        public DateTime? desde { get; set; } = null;
        public DateTime? hasta { get; set; } = null;
    }

    #region para consultar api permisoList
    public class PermisoModel
    {
        public int IdPermiso { get; set; }
        public int IdColaborador { get; set; }
        public DateTime? FechaSolicitud { get; set; }
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Motivo { get; set; }
        public string Asunto { get; set; }
        public string Descripcion { get; set; }  
        public string Estado { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaActualizacion { get; set; }
    }

    public class ListarPermisoResponse
    {
        public List<ClassPermiso_List>? ListarPermiso { get; set; }
        public string Message { get; set; }
    }

    public class ListarPermisoResponseID
    {
        public ClassPermiso_List? ListarPermiso { get; set; }
        public string Message { get; set; }
    }
    #endregion
}
