using ApiControlTiempo.Class;
using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using static ApiControlTiempo.Class.ClassGestionColaboradores;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    [ApiController]
    public class GestionColaboradoresController : Controller
    {
        [HttpPut("CrearColaborador")]
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

                if (Resp == null)
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

        [HttpPost("ActualizarColaborador")]
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

                if (Resp == null)
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

        [HttpGet("ConsultarColaboradorId/{Id_colaborador}")]
        public IActionResult ConsultaColaboradorID(int Id_colaborador)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnetionGestionColaboradores Aut = new ConnetionGestionColaboradores(configuration);
                ClassConsultarColaborador objJson = Aut.Connec_ConsultarColaboradorID(Id_colaborador);
                string mensaje = string.Empty;

                if (objJson == null)
                {
                    mensaje = "No se se encontró un registro con ese ID, por favor reinténtelo";
                }
                else 
                {
                    mensaje = "Consultado con éxito";
                }

                return Ok(new { objJson, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ConsultarColaboradorFiltro")]
        public IActionResult ConsultarColaboradorFiltro([FromBody] ClassConsultarColaboradorFiltro objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnetionGestionColaboradores Aut = new ConnetionGestionColaboradores(configuration);
                List<ClassConsultarColaborador> Resp = Aut.Connec_ConsultarColaboradorFiltro(objJson);

                string mensaje = string.Empty;

                if (Resp == null)
                {
                    mensaje = "No se se encontró un registro con ese ID, por favor reinténtelo";
                }
                else
                {
                    mensaje = "Consultado con éxito";
                }

                return Ok(new { Resp, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ActColaboradorEstado")]
        public IActionResult ActColaboradorEstado([FromBody] ClassActColaboradorEstado objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                string mensaje = string.Empty;

                ConnetionGestionColaboradores Aut = new ConnetionGestionColaboradores(configuration);
                mensaje = Aut.Connec_ActColaboradorEstado(objJson);

                

                if (string.IsNullOrEmpty(mensaje))
                {
                    mensaje = "No se pudo actualizar el estado, por favor reinténtelo";
                }

                return Ok(new { message = mensaje });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
