using ApiControlTiempo.Class;
using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using static ApiControlTiempo.Class.ClassTareasyAsignaciones;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    [ApiController]
    public class TareasyAsignacionesController : Controller
    {
        [HttpPut("AsignacionTareaCreate")]
        public IActionResult AsignacionTareaCreate([FromBody] ClassAsignacion_Create obj_Json)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionTareasyAsignaciones Aut = new ConnectionTareasyAsignaciones(configuration);
                ClassAsignacion_Create resp = Aut.Connec_Asignacion_Create(obj_Json);

                if (resp == null)
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { resp, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("AsignacionTareaListar")]
        public IActionResult AsignacionTareaListar([FromBody] ClassAsignacion_List obj_Json)
        {
            try
            {
                string mensaje = string.Empty;
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionTareasyAsignaciones Aut = new ConnectionTareasyAsignaciones(configuration);
                List<ClassAsignacion_List_Resp> Lista = Aut.Connec_Asignacion_List(obj_Json);

                if (Lista.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { Lista, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("TareaCreate")]
        public IActionResult TareaCreate([FromBody] ClassTarea_Create obj_Json)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionTareasyAsignaciones Aut = new ConnectionTareasyAsignaciones(configuration);
                ClassTarea_Create resp = Aut.Connec_Tarea_Create(obj_Json);

                if (resp == null)
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { resp, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("TareaUpdate")]
        public IActionResult TareaUpdate([FromBody] ClassTarea_Update obj_Json)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionTareasyAsignaciones Aut = new ConnectionTareasyAsignaciones(configuration);
                string mensaje = Aut.Connec_Tarea_Update(obj_Json);

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

        [HttpPost("TareaList")]
        public IActionResult TareaList(ClassTareaListParam obj)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;

                ConnectionTareasyAsignaciones Aut = new ConnectionTareasyAsignaciones(configuration);
                List<ClassTareaList> ListTareas = Aut.Connec_Tarea_List(obj);

                if (ListTareas.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay tareas para mostrar";
                }

                return Ok(new { ListTareas, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
