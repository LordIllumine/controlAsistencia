using ApiControlTiempo.Class;
using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using static ApiControlTiempo.Class.ClassGestionColaboradores;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    [ApiController]
    public class ControlAsistenciaController : Controller
    {
        [HttpPost("editarRegistros")]
        public IActionResult editarRegistros([FromBody] ClassControlAsistencia objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionControlAsistencia Aut = new ConnectionControlAsistencia(configuration);
                string mensaje = Aut.Connec_AsistenciaEditarRegistro(objJson);

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

        [HttpPost("ConsultarPorIdAsistencia")]
        public IActionResult ConsultarPorIdAsistencia([FromBody] ClassControlAsistenciaGetByRango objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionControlAsistencia Aut = new ConnectionControlAsistencia(configuration);
                List<ClassControlAsistenciaResp> AsistenciaResp = Aut.Connec_Asistencia_GetByRango(objJson);

                if (AsistenciaResp.Count > 0)
                {
                    mensaje = "Respuesta exitosa";
                }
                else 
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { AsistenciaResp, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ConsultarAsistenciaHoras")]
        public IActionResult ConsultarAsistenciaHoras([FromBody] ClassControlAsistenciaGetByRango objJson)
        {
            //SP_Asistencia_ResumenHoras
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionControlAsistencia Aut = new ConnectionControlAsistencia(configuration);
                List<ClassAsistenciaHoras> AsistenciaResp = Aut.Connec_Asistencia_Horas(objJson);

                if (AsistenciaResp.Count > 0)
                {
                    mensaje = "Respuesta exitosa";
                }
                else
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { AsistenciaResp, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("AsistenciaMarcarEntrada")]
        public IActionResult AsistenciaMarcarEntrada([FromBody] ClassAsistenciaMarcarEntrada obj_Json)
        {
            try
            {
                //ClassAsistenciaMarcarEntrada obj_Json = new ClassAsistenciaMarcarEntrada();
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionControlAsistencia Aut = new ConnectionControlAsistencia(configuration);
                string mensaje = Aut.Connec_Asistencia_MarcarEntrada(obj_Json);

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

        [HttpPost("AsistenciaMarcarSalida")]
        public IActionResult AsistenciaMarcarSalida([FromBody] ClassAsistenciaMarcarSalida obj_Json)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionControlAsistencia Aut = new ConnectionControlAsistencia(configuration);
                string mensaje = Aut.Connec_Asistencia_MarcarSalida(obj_Json);

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
    }
}
