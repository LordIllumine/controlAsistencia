using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class ActividadesAsignadasController : Controller
    {
        public ActionResult ActividadesAsignadas()
        {
            var model = new ClassActividadesAsignadasViewModel
            {
                ActividadesAsig = new List<ClassActividadesAsignadas>() // Lista vacía en vez de null
            };

            return View(model);
        }
    }
}
