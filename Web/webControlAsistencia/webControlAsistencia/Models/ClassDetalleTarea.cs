using Microsoft.AspNetCore.Mvc.Rendering;
using System.ComponentModel.DataAnnotations;
using System.Runtime.Serialization;

namespace webControlAsistencia.Models
{
    public class ClassDetalleTarea
    {
        [Display(Name = "Id tarea")]
        public int? Id { get; set; }

        [Display(Name = "Actividad")]
        public string? Actividad { get; set; }

        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }

        [Display(Name = "Fecha y hora inicio")]
        public DateTime? FechaInicio { get; set; }

        [Display(Name = "Fecha y hora fin")]
        public DateTime? FechaFin { get; set; }

        public string? EstadoTarea { get; set; }
        public string? EstadoAsignacion { get; set; }
        public int IdColaboradorSeleccionado { get; set; }
        public List<Asignacion>? ListTareasAsignadas { get; set; }
        public List<ClassConsultarColaborador>? ListColaboradores { get; set; }
    }

    #region RepColaboradores
    public class ClassConsultarColaborador
    {
        public int idColaborador { get; set; }
        public string nombre { get; set; }
        public string apellido { get; set; }
        public string correo { get; set; }
        public string telefono { get; set; }
        public string rol { get; set; }
        public bool estado { get; set; }
    }

    public class RespuestaJSON
    {
        public List<ClassConsultarColaborador>? objJson { get; set; }
    }


    #endregion

    #region Leer los colaboradores asignados
    public class Asignacion
    {
        public int IdTarea { get; set; }
        public int IdAsignacion { get; set; }
        public DateTime FechaAsignacion { get; set; }
        public string EstadoAsignacion { get; set; }
        public int IdColaborador { get; set; }
        public string NombreColaborador { get; set; }
        public string Apellido { get; set; }
        public string Correo { get; set; }
        public string Telefono { get; set; }
        public string Rol { get; set; }
        public string EstadoColaborador { get; set; }
    }

    public class ResponseAsignaciones
    {
        public List<Asignacion>? ListAsignaciones { get; set; }
        public string Message { get; set; }
    }

    #endregion

    #region consultar la info de la tarea
    public class ClassDetalleTareaJson
    {
        public Tarea listTareas { get; set; }
        public string message { get; set; }
    }

    public class Tarea
    {
        public int idTarea { get; set; }
        public string nombre { get; set; }
        public string descripcion { get; set; }
        public string estadoTarea { get; set; }
        public DateTime fechaIniTarea { get; set; }
        public DateTime fechafinTarea { get; set; }
    }
    #endregion

    #region Update Tarea y asignacion
    public class UpdateTarea
    {
        public int? idTarea { get; set; }
        public string nombre { get; set; }
        public string descripcion { get; set; }
        public string estadoTarea { get; set; }
        public DateTime? fechaInicio { get; set; }
        public DateTime? fechaFin { get; set; }
    }

    public class UpdateAsignacion
    {
        public int? idColaborador { get; set; }
        public int? idTarea { get; set; }
        public DateTime? fechaAsignacion { get; set; }
    }
    #endregion
}
