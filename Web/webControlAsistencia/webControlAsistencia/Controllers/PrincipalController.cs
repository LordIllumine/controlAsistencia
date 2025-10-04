using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace webControlAsistencia.Controllers
{
    public class PrincipalController : Controller
    {
        public static string Usuario;
        public static string Rol;
        public static string Token;

        // GET: PrincipalController
        public ActionResult Principal()
        {
            // Recuperar los datos que vienen del login
            if (HttpContext.Session.GetString("Usuario") != null)
            {
                Usuario = HttpContext.Session.GetString("Usuario");
                Rol = HttpContext.Session.GetString("Rol");
                Token = HttpContext.Session.GetString("Token");
            }

            //si quisieramos borrar la session 
            //HttpContext.Session.Remove("Usuario");


            return View();
        }
    }
}
