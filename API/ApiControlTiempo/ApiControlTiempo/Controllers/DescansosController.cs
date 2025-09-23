using ApiControlTiempo.Class;
using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using static ApiControlTiempo.Class.ClassDescansos;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    [ApiController]
    public class DescansosController : Controller
    {
        [HttpPost("Descanso_Iniciar")]
        public IActionResult Descanso_Iniciar([FromBody] ClassDescanso_Iniciar objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionDescansos Aut = new ConnectionDescansos(configuration);
                string mensaje = Aut.Connec_Descanso_Iniciar(objJson);

                if (string.IsNullOrEmpty(mensaje))
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("Descanso_Finalizar")]
        public IActionResult Descanso_Finalizar([FromBody] ClassDescanso_Finalizar objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionDescansos Aut = new ConnectionDescansos(configuration);
                string mensaje = Aut.Connec_Descanso_Finalizar(objJson);

                if (string.IsNullOrEmpty(mensaje))
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("Descanso_Resumen")]
        public IActionResult Descanso_Resumen([FromBody] ClassDescanso_Resumen objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionDescansos Aut = new ConnectionDescansos(configuration);
                List<ClassDescanso_ResumenResp> ListDescanso = Aut.Connec_Descanso_Resumen(objJson);

                if (ListDescanso.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay Descansos para mostrar";
                }

                return Ok(new { ListDescanso, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
