using ApiControlTiempo.Class;
using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using static ApiControlTiempo.Class.ClassGestionColaboradores;

namespace ApiControlTiempo.Controllers
{
    public class GestionColaboradoresController : Controller
    {
        [HttpPost("CrearColaborador")]
        public IActionResult CrearColaborador([FromBody] ClassActColaborador objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnetionGestionColaboradores Aut = new ConnetionGestionColaboradores(configuration);
                ClassActColaboradorResp Resp = Aut.Connec_ActColaborador(objJson);

                if (objJson == null)
                {
                    Resp.Mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { message = Resp.Mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("ActualizarColaborador")]
        public IActionResult ResetPassword([FromBody] ClassCrearColaborador objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnetionGestionColaboradores Aut = new ConnetionGestionColaboradores(configuration);
                ClassCrearColaboradorResp Resp = Aut.Connec_CrearColaborador(objJson);

                if (objJson == null)
                {
                    Resp.Mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { message = Resp.Mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }


    }
}
