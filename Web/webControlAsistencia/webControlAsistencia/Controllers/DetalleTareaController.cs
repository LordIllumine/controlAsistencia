using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.Elfie.Serialization;
using Newtonsoft.Json;
using System.Text;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class DetalleTareaController : Controller
    {
        public static string IdColaborador;
        public static string Usuario;
        public static string Rol;
        public static string Token;

        private readonly ILogger<DetalleTareaController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;


        public DetalleTareaController(ILogger<DetalleTareaController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        [HttpGet("DetalleTarea/{id}")]
        public async Task<ActionResult> DetalleTarea(int id)
        {
            // Recuperar los datos que vienen del login
            string IdColaborador = string.Empty;
            string Usuario = string.Empty;
            string Rol = string.Empty;
            string Token = string.Empty;

            if (HttpContext.Session.GetString("Usuario") != null)
            {
                IdColaborador = HttpContext.Session.GetString("IdColaborador");
                Usuario = HttpContext.Session.GetString("Usuario");
                Rol = HttpContext.Session.GetString("Rol");
                Token = HttpContext.Session.GetString("Token");
            }

            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(baseUrl);
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(
                    new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                if (!string.IsNullOrEmpty(Token))
                {
                    client.DefaultRequestHeaders.Authorization =
                        new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", Token);
                }

                //Petición GET
                HttpResponseMessage response = await client.GetAsync($"api/TareasyAsignaciones/TareaListId/{id}");

                if (response.IsSuccessStatusCode)
                {
                    var result = await response.Content.ReadAsStringAsync();

                    // Deserializar el objeto completo que contiene listTareas y message
                    ClassDetalleTareaJson jsonResp = JsonConvert.DeserializeObject<ClassDetalleTareaJson>(result);

                    ClassDetalleTarea obj = new ClassDetalleTarea();
                    obj.Id = jsonResp.listTareas.idTarea;
                    obj.Actividad = jsonResp.listTareas.nombre;
                    obj.Descripcion = jsonResp.listTareas.descripcion;
                    obj.FechaInicio = jsonResp.listTareas.fechaIniTarea;
                    obj.FechaFin = jsonResp.listTareas.fechafinTarea;
                    obj.EstadoTarea = jsonResp.listTareas.estadoTarea;
                    obj.ListTareasAsignadas = null; // inicializo la lista por si no hay colaboradores asignados

                    #region Leer del api los asignados a la tarea
                    using (HttpClient clientA = new HttpClient())
                    {
                        clientA.BaseAddress = new Uri(baseUrl);
                        clientA.DefaultRequestHeaders.Accept.Clear();
                        clientA.DefaultRequestHeaders.Accept.Add(
                            new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                        if (!string.IsNullOrEmpty(Token))
                        {
                            clientA.DefaultRequestHeaders.Authorization =
                                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", Token);
                        }

                        //Petición GET
                        HttpResponseMessage responseA = await clientA.GetAsync($"api/TareasyAsignaciones/AsignacionesListId/IdTarea/{id}/IdColaborador/{IdColaborador}");

                        if (responseA.IsSuccessStatusCode)
                        {
                            var resultA = await responseA.Content.ReadAsStringAsync();

                            // Deserializar el objeto completo 
                            ResponseAsignaciones jsonRespA = JsonConvert.DeserializeObject<ResponseAsignaciones>(resultA);

                            obj.ListTareasAsignadas = jsonRespA.ListAsignaciones ?? null;
                        }
                        else
                        {
                            ViewBag.Error = "Error al cargar los datos delos colaboradores asignados a la tarea.";
                            return View();
                        }
                    }
                    #endregion

                    if (!string.IsNullOrEmpty(Rol) && Rol.Equals("Administrador"))
                    {
                        ViewBag.Validar = "1"; //Lo hago con números por seguridad, de esta manera el inspeccionar no mostrara el dato del rol
                    }
                    else
                    {
                        ViewBag.Validar = "0";
                    }

                    return View(obj);
                }
                else
                {
                    ViewBag.Error = "Error al cargar los datos de la tarea.";
                    return View();
                }
            }
        }
    }
}
