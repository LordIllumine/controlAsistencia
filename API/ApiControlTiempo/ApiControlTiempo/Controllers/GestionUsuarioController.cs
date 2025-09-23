using ApiControlTiempo.Class;
using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Mvc;
using System.Net.Mail;
using System.Net;
using Microsoft.AspNetCore.Authorization;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    [ApiController]
    public class GestionUsuarioController : Controller
    {
        [HttpPost("ResetPassword")]
        public IActionResult ResetPassword([FromBody] ClassResetPassword ResetPass)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionAuthentificate Aut = new ConnectionAuthentificate(configuration);
                string Mensaje = Aut.Connec_ResetPassword(ResetPass);

                if (string.IsNullOrEmpty(Mensaje))
                {
                    Mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { message = Mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ResetPasswordRequest")]
        public IActionResult ResetPasswordRequest(ClassResetPasswordRequest ResetPass)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionAuthentificate Aut = new ConnectionAuthentificate(configuration);
                ClassResetPasswordRequest ObjResp = Aut.Connec_ResetPasswordRequest(ResetPass);

                if (ObjResp == null)
                {
                    ObjResp.Mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                //ENVIO DE CORREO
                #region ENVIO DE CORREO
                string correoReseptor = ResetPass.correo;

                // Leer configuración del correo
                var emailSettings = configuration.GetSection("EmailSettings").Get<EmailSettings>();

                // OPCIONAL (SOLO PARA PRUEBAS): Ignorar validación de certificado
                // NO USAR EN PRODUCCIÓN
                ServicePointManager.ServerCertificateValidationCallback = (sender, certificate, chain, sslPolicyErrors) => true;

                // Crear mensaje de correo
                MailMessage mail = new MailMessage
                {
                    From = new MailAddress(emailSettings.From),
                    Subject = "Recuperación de contraseña",
                    IsBodyHtml = true,
                    Body = $@"
                <html>
                    <body style='font-family: Arial;'>
                        <h2>Recuperación de Contraseña</h2>
                        <p>Se ha solicitado una recuperación de contraseña para su cuenta copie el siguiente token y péguelo en la pantalla de recuperación del sistema.</p>
                        <p><strong>Token:</strong> {ObjResp.token}</p>
                        <p>Si usted no realizó esta solicitud, puede ignorar este correo y comunicarse con el equipo de soporte.</p>
                        <br />
                        <p>Atentamente,<br />Equipo de Soporte</p>
                    </body>
                </html>"
                };
                mail.To.Add(correoReseptor);

                using (SmtpClient smtp = new SmtpClient(emailSettings.SmtpServer, emailSettings.Port))
                {
                    smtp.Credentials = new NetworkCredential(emailSettings.From, emailSettings.Password);
                    smtp.EnableSsl = true;

                    smtp.Send(mail); // Enviar correo
                }
                #endregion

                return Ok(new { ObjResp });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ResetPasswordConfirm")]
        public IActionResult ResetPasswordConfirm([FromBody] ClassResetPasswordComfirm Pass)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionAuthentificate Aut = new ConnectionAuthentificate(configuration);
                string Mensaje = Aut.Connec_ResetPasswordConfirm(Pass);

                if (string.IsNullOrEmpty(Mensaje))
                {
                    Mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { message = Mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
