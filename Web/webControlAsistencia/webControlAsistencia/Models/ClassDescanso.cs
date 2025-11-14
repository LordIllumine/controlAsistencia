using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassDescanso
    {
        public int idDescanso { get; set; }
        [Display(Name = "Tipo de Descanso")]
        public string? TipoDescansos { get; set; }
        [Display(Name = "Descripción")]
        public string? Descripcion { get; set; }
        public List<ClassDescanso_List>? ListDescanso { get; set; } = null;
    }

    public class ClassDescanso_Obj
    {
        [Required]
        public int idColaborador { get; set; }
        public string? tipoDescanso { get; set; } = null;
        public DateTime? fechaInicio { get; set; } = null;
        public DateTime? fechaFin { get; set; } = null;
    }

    public class ClassDescanso_List
    {
        public int idDescanso { get; set; }
        public int idColaborador { get; set; }
        public string? NombreColaborador { get; set; }
        public string? Correo { get; set; }
        public string? Descripcion { get; set; }
        public string? tipoDescanso { get; set; }
        public DateTime? fechaInicio { get; set; }
        public DateTime? fechaFin { get; set; }
        public string? estado { get; set; }
    }

    //public class DescansoResp
    //{
    //    public int IdDescanso { get; set; }
    //    public int IdColaborador { get; set; }
    //    public string NombreColaborador { get; set; }
    //    public string Correo { get; set; }
    //    public string Descripcion { get; set; }
    //    public string TipoDescanso { get; set; }
    //    public DateTime FechaInicio { get; set; }
    //    public DateTime FechaFin { get; set; }
    //    public string Estado { get; set; }
    //}

    public class DescansoApi
    {
        public List<ClassDescanso_List>? Listar { get; set; }
        public string Message { get; set; }
    }

    public class Respu
    {
        public int IdColaborador { get; set; }
        public string TipoDescanso { get; set; }
        public int IdDescanso { get; set; }
        public string Mensaje { get; set; }
    }

    public class IniciarDescansoResp
    {
        public Respu Resp { get; set; }
    }
}
