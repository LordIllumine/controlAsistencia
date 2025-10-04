using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassLogin
    {
        //[Required(ErrorMessage = "El campo Identificación es obligatorio.")]
        [Display(Name = "Usuario")]
        public string usuario { get; set; }

        //[Required(ErrorMessage = "La contraseña es obligatoria.")]
        [Display(Name = "Contraseña")]
        public string contrasena { get; set; }
    }

    public class ClassLoginResp
    {
        public string Usuario { get; set; }
        public string Contrasena { get; set; }
        public string? Rol { get; set; } = null;
        public int? IdColaborador { get; set; }
        public string? Token { get; set; }
    }
}
