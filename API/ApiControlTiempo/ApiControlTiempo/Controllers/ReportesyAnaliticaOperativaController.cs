using ApiControlTiempo.Connection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using static ApiControlTiempo.Class.ClassPermisos;
using static ApiControlTiempo.Class.ClassReportesyAnaliticaOperativa;
using static ApiControlTiempo.Class.ClassTareasyAsignaciones;

namespace ApiControlTiempo.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    [ApiController]
    public class ReportesyAnaliticaOperativaController : Controller
    {
        [HttpGet("ReporteAsistenciaDiaria/{ParametroBusqueda}")]
        public IActionResult TareaList(DateTime ParametroBusqueda)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;

                ConnectionReportesyAnaliticaOperativa Aut = new ConnectionReportesyAnaliticaOperativa(configuration);
                List<ClassReporte_AsistenciaDiaria> ListReporte = Aut.Connec_Reporte_AsistenciaDiaria(ParametroBusqueda);

                if (ListReporte.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay datos para mostrar";
                }

                return Ok(new { ListReporte, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ReporteHorasTrabajadas")]
        public IActionResult ReporteHorasTrabajadas(ClassReporte_HorasTrabajadas objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;

                ConnectionReportesyAnaliticaOperativa Aut = new ConnectionReportesyAnaliticaOperativa(configuration);
                List<ClassReporte_HorasTrabajadasResp> ListReporte = Aut.Connec_Reporte_HorasTrabajadas(objJson);

                if (ListReporte.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay datos para mostrar";
                }

                return Ok(new { ListReporte, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ReportePermisos")]
        public IActionResult ReportePermisos([FromBody] ClassReporte_Permisos objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionReportesyAnaliticaOperativa Aut = new ConnectionReportesyAnaliticaOperativa(configuration);
                List<ClassReporte_PermisosResp> ListarPermiso = Aut.Connec_Reporte_Permisos(objJson);

                if (ListarPermiso.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay datos para mostrar";
                }

                return Ok(new { ListarPermiso, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("ReporteProductividad")]
        public IActionResult ReporteProductividad([FromBody] ClassReporte_Productividad objJson)
        {
            try
            {
                // Consultar usuario en BD
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();
                string mensaje = string.Empty;
                ConnectionReportesyAnaliticaOperativa Aut = new ConnectionReportesyAnaliticaOperativa(configuration);
                List<ClassReporte_ProductividadResp> ListarReporte = Aut.Connec_Reporte_Productividad(objJson);

                if (ListarReporte.Count > 0)
                {
                    mensaje = "Consulta exitosa";
                }
                else
                {
                    mensaje = "No hay datos para mostrar";
                }

                return Ok(new { ListarReporte, message = mensaje });

            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
