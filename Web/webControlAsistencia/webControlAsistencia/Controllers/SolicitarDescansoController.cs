using Microsoft.AspNetCore.Mvc;

namespace webControlAsistencia.Controllers
{
    public class SolicitarDescansoController : Controller
    {
        public IActionResult SolicitarDescanso()
        {
            return View();
        }
    }
}
