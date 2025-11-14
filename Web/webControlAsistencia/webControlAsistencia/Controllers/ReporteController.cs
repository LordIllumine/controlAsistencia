using Microsoft.AspNetCore.Mvc;
using webControlAsistencia.Filters;

namespace webControlAsistencia.Controllers
{
    [SessionAuthorize]
    public class ReporteController : Controller
    {
        public IActionResult Reporte()
        {
            return View();
        }
    }
}
