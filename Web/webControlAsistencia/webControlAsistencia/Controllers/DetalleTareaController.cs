using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class DetalleTareaController : Controller
    {
        public ActionResult DetalleTarea()
        {
            
            ClassDetalleTarea obj = new ClassDetalleTarea();
            obj.Id = 1;
            obj.Actividad = "Solución Error";
            obj.Descripcion = "Solucionar bug de pantalla inicio";
            obj.FechaInicio = null;
            obj.FechaFin = null;

            return View(obj);
        }
    }
}
