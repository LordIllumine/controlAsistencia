using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace webControlAsistencia.Controllers
{
    public class PrincipalController : Controller
    {
        // GET: PrincipalController
        public ActionResult Principal()
        {
            return View();
        }
    }
}
