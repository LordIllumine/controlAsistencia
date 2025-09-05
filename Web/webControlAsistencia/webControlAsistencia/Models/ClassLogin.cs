using System.ComponentModel.DataAnnotations;

namespace webControlAsistencia.Models
{
    public class ClassLogin
    {
        //[Required(ErrorMessage = "El campo Identificación es obligatorio.")]
        [Display(Name = "Identificación")]
        public string Identificacion { get; set; }

        //[Required(ErrorMessage = "La contraseña es obligatoria.")]
        [Display(Name = "Contraseña")]
        public string Contrasenna { get; set; }
    }
}
