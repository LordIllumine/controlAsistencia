using ApiControlTiempo.Class;
using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Net.Mail;
using System.Net;
using System.Security.Claims;
using System.Text;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AutentificateController : ControllerBase
    {
        [HttpPost("GetToken")]
        public IActionResult Post([FromBody] ClassAuthentificate Log)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                ConnectionAuthentificate Aut = new ConnectionAuthentificate(configuration);
                List<ClassAuthentificate> usuarioExiste = Aut.Connec_Authentication(Log);

                ClassAuthentificateMessage ResUser = new ClassAuthentificateMessage();

                //string contraDesencryptada = string.Empty;
                string mensaje = string.Empty;
                if (usuarioExiste.Count > 0)
                {
                    // Desencriptamos la contraseña del usuario almacenada en BD
                    foreach (var itemContra in usuarioExiste)
                    {
                        #region Encriptar / Desencriptar
                        //Cryptografia a = new Cryptografia();
                        //contraDesencryptada = a.DecryptString(itemContra.Contrasena, "");
                        #endregion

                        if (string.Equals(Log.Usuario, itemContra.Usuario, StringComparison.OrdinalIgnoreCase) && Log.Contrasena.Equals(itemContra.Contrasena))
                        {
                            mensaje = itemContra.Mensaje;
                            // Generación de Token para mantener activa la sesión del usuario
                            #region JWT
                            var jwtKey = configuration["Jwt:Key"];
                            var jwtIssuer = configuration["Jwt:Issuer"];
                            var jwtAudience = configuration["Jwt:Audience"];

                            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
                            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

                            var claims = new[]
                            {
                                new Claim(ClaimTypes.Name, Log.Usuario),
                                new Claim("Rol", itemContra.Rol ?? "Usuario") // Puedes agregar más claims aquí
                            };

                            var token = new JwtSecurityToken(
                                issuer: jwtIssuer,
                                audience: jwtAudience,
                                claims: claims,
                                expires: DateTime.Now.AddMinutes(6000), // Token válido por 6000 minutos = 100 horas
                                signingCredentials: credentials
                            );

                            var tokenString = new JwtSecurityTokenHandler().WriteToken(token);

                            // Generamos el objeto de respuesta con la información del Perfil del usuario
                            #region Respuesta
                            ResUser = new ClassAuthentificateMessage();
                            ResUser.autenticado = true;
                            ResUser.Usuario = Log.Usuario;
                            ResUser.Rol = itemContra.Rol;
                            ResUser.Token = tokenString;
                            ResUser.message = mensaje;
                            #endregion

                            return Ok(new { ResUser });
                            #endregion
                        }
                    }
                }

                #region Respuesta si no se encontro el usuario
                ResUser.autenticado = false;
                ResUser.Usuario = Log.Usuario;
                ResUser.Rol = Log.Rol;
                ResUser.Token = "";
                ResUser.message = mensaje;
                #endregion

                return Ok(new { ResUser });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

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
