using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassAuthentificate
    {
        [JsonRequired]
        public string Usuario { get; set; }
        [JsonRequired]
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
        public string Usuario { get; set; }
        public string Rol { get; set; }
        public string Token { get; set; }
        public string message { get; set; }
    }

    public class ClassResetPassword
    {
        [JsonRequired]
        public int idColaborador { get; set; }
        [JsonRequired]
        public string passwordActual { get; set; }
        [JsonRequired]
        public string passwordNueva { get; set; }
        [JsonIgnore]
        public string? Mensaje { get; set; }
    }

    public class ClassResetPasswordRequest
    {
        //[JsonRequired]
        public string correo { get; set; }
        //[JsonIgnore]
        public string token { get; set; }
        //[JsonIgnore]
        public string? Mensaje { get; set; }
    }

    public class ClassResetPasswordComfirm
    {
        [JsonRequired]
        public string correo { get; set; }
        [JsonRequired]
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
