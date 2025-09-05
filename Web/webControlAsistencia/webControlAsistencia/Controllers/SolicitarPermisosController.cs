using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class SolicitarPermisosController : Controller
    {
        // GET: SolicitarPermisosController
        public ActionResult SolicitarPermisos()
        {           
            return View();
        }
    }
}
