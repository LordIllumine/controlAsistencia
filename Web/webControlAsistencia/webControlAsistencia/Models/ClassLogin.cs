using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassLogin
    {
        [Required(ErrorMessage = "El campo Identificación es obligatorio.")]
        [Display(Name = "Usuario")]
        public string usuario { get; set; }

        [Required(ErrorMessage = "La contraseña es obligatoria.")]
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

    public class ClassResetPassword
    {
        [Display(Name = "Ingrese el Correo")]
        public string? Correo { get; set; }

        //[Display(Name = "Ingrese el Token")]
        //public string? Token { get; set; }
        //[Display(Name = "Ingrese la nueva contraseña")]
        //public string? NuevaContraseña { get; set; }
    }

    public class ClassValidoToken
    {
        public string? Ip { get; set; }

        [Display(Name = "Ingrese el Token")]
        public string? Token { get; set; }

        [Display(Name = "Ingrese la nueva contraseña")]
        public string? NuevaContraseña { get; set; }
    }

    public class ClassResetPasswordRequestAPI
    {
        public string? IP { get; set; }
        public string correo { get; set; }
        public string? token { get; set; }
    }

}