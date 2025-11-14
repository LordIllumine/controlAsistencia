using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassAuthentificate
    {
        [Required]
        public string Usuario { get; set; }
        [Required]
        public string Contrasena { get; set; }

        [JsonIgnore]
        public string? Rol { get; set; } = null;
        [JsonIgnore]
        public int? IdColaborador { get; set; }
        [JsonIgnore]
        public string? Mensaje { get; set; }
    }

    public class ClassAuthentificateMessage
    {
        public bool autenticado { get; set; }
        public int? IdColaborador { get; set; }
        public string Usuario { get; set; }
        public string Rol { get; set; }
        public string Token { get; set; }
        public string message { get; set; }
    }

    public class ClassResetPassword
    {
        [Required]
        public int idColaborador { get; set; }
        [Required]
        public string passwordActual { get; set; }
        [Required]
        public string passwordNueva { get; set; }
        [JsonIgnore]
        public string? Mensaje { get; set; }
    }

    public class ClassResetPasswordRequest
    {
        //[Required]
        public string IP { get; set; }
        public string correo { get; set; }
        //[JsonIgnore]
        public string token { get; set; }
        //[JsonIgnore]
        public string? Mensaje { get; set; }
    }

    public class ClassResetPasswordComfirm
    {
        [Required]
        public string token { get; set; }
        [Required]
        public string correo { get; set; }
        [Required]
        public string passwordNueva { get; set; }
        [JsonIgnore]
        public string? Mensaje { get; set; }
    }

    #region EnvioCorreo
    public class EmailSettings
    {
        public string From { get; set; }
        public string Password { get; set; }
        public string SmtpServer { get; set; }
        public int Port { get; set; }
    }
    #endregion
}
