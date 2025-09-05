using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Reflection;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        //Este es el Login 
        public IActionResult Index(ClassLogin obj)
        {
            if (!ModelState.IsValid)
            {
                // Si hay errores, vuelve a la vista con mensajes
                return View();
            }

            if (obj == null)
            {
                // Lógica si todo es válido
                return RedirectToAction("Index");
            }
            else 
            {
                // Lógica si todo es válido
                return RedirectToAction("Principal", "Principal");
            }
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
