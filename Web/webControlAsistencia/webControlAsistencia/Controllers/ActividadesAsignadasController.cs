using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class ActividadesAsignadasController : Controller
    {
        public ActionResult ActividadesAsignadas(string filtro, DateTime? fechaInicio, DateTime? fechaFin)
        {
            var model = new ClassActividadesAsignadasViewModel
            {
                ActividadesAsig = new List<ClassActividadesAsignadas>()
            };

            if (filtro != null) 
            {
                if(filtro.Equals("Todos") || filtro.Equals("Todos"))
            }

            return View(model);
        }
    }
}
