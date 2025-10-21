using Microsoft.AspNetCore.Mvc;

namespace webControlAsistencia.Controllers
{
    public class ReporteController : Controller
    {
        public IActionResult Reporte()
        {
            return View();
        }
    }
}
