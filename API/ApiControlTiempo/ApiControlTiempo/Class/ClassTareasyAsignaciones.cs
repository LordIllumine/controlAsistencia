using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace ApiControlTiempo.Class
{
    public class ClassTareasyAsignaciones
    {
        public class ClassAsignacion_Create
        {
            [Required]
            public int idColaborador { get; set; }
            [Required]
            public int idTarea { get; set; }
            [Required]
            public DateTime fechaAsignacion{ get; set; }
            public int? idAsignacion { get; set; } = null;
            public string? mensaje { get; set; } = null;
        }

        public class ClassAsignacion_List
        {
            [Required]
            public int idColaborador { get; set; }
            [Required]
            public int idTarea { get; set; }
            [Required]
            public DateTime desde { get; set; }
            [Required]
            public DateTime hasta { get; set; }
        }

        public class ClassAsignacion_List_Resp
        {
            public int idAsignacion { get; set; }
            public int idColaborador { get; set; }
            public int idTarea { get; set; }
            public DateTime? fechaAsignacion { get; set; }
            public DateTime? fechaCreacion { get; set; }
            public DateTime? fechaActualizacion { get; set; }
        }

        public class ClassTarea_Create
        {
            [Required]
            public string nombre { get; set; }
            [Required]
            public string descripcion { get; set; }
            public int? idTarea { get; set; } = null;
            public string? mensaje { get; set; } = null;
        }

        public class ClassTarea_Update
        {
            [Required]
            public int idTarea { get; set; }
            [Required]
            public string nombre { get; set; }
            [Required]
            public string descripcion { get; set; }
            public string? mensaje { get; set; } = null;
        }

        public class ClassTareaList
        {
            public int idTarea { get; set; }
            public string? Nombre { get; set; }
            public string? Descripcion { get; set; }
            public DateTime? fechaCreacion { get; set; }
            public DateTime? fechaActualizacion { get; set; }
        }
    }
}
