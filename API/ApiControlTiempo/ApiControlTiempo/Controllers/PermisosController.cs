using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using static ApiControlTiempo.Class.ClassDescansos;
using static ApiControlTiempo.Class.ClassPermisos;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    [ApiController]
    public class PermisosController : Controller
    {
        [HttpPut("Permiso_Solicitar")]
        public IActionResult Permiso_Solicitar([FromBody] ClassPermiso_Solicitar objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionPermisos Aut = new ConnectionPermisos(configuration);
                ClassPermiso_Solicitar ObjPermiso = Aut.Connec_Permiso_Solicitar(objJson);

                if (ObjPermiso == null)
                {
                    mensaje = "No se obtuvo respuesta del servidor, por favor reinténtelo";
                }

                return Ok(new { ObjPermiso, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("EditarPermiso_Solicitar")]
        public IActionResult EditarPermiso_Solicitar([FromBody] ClassEditarPermiso_Solicitar objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                ConnectionPermisos Aut = new ConnectionPermisos(configuration);
                string mensaje = Aut.Connec_EditarPermiso_Solicitar(objJson);

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

        [HttpPost("ListarPermisos")]
        public IActionResult ListarPermisos([FromBody] ClassPermiso_List objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionPermisos Aut = new ConnectionPermisos(configuration);
                List <ClassPermiso_List_Resp> ListarPermiso = Aut.Connec_PermisoList(objJson);

                if (ListarPermiso.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay Permisos para mostrar";
                }

                return Ok(new { ListarPermiso, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ListarPermisosID")]
        public IActionResult ListarPermisosID([FromBody] ClassPermiso_Id objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionPermisos Aut = new ConnectionPermisos(configuration);
                ClassPermiso_List_Resp ListarPermiso = Aut.Connec_PermisoID(objJson);

                if (ListarPermiso != null)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay Permisos para mostrar";
                }

                return Ok(new { ListarPermiso, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

    }
}
