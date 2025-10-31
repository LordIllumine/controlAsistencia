using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.CodeAnalysis.Elfie.Serialization;
using Newtonsoft.Json;
using System.Text;
using System.Threading.Tasks;
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

                    #region Leer del api los Colaboradores
                    using (HttpClient clientC = new HttpClient())
                    {
                        clientC.BaseAddress = new Uri(baseUrl);
                        clientC.DefaultRequestHeaders.Accept.Clear();
                        clientC.DefaultRequestHeaders.Accept.Add(
                            new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                        if (!string.IsNullOrEmpty(Token))
                        {
                            clientC.DefaultRequestHeaders.Authorization =
                                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", Token);
                        }

                        //Petición GET
                        HttpResponseMessage responseC = await clientC.GetAsync($"api/GestionColaboradores/ConsultarColaboradorId/{IdColaborador}");

                        if (responseC.IsSuccessStatusCode)
                        {
                            var resultC = await responseC.Content.ReadAsStringAsync();
                            // Deserializar el objeto completo 
                            RespuestaJSON jsonRespC = JsonConvert.DeserializeObject<RespuestaJSON>(resultC);
                            obj.ListColaboradores = jsonRespC.objJson ?? null;
                        }
                        else
                        {
                            ViewBag.Error = "Error al cargar los datos delos colaboradores asignados a la tarea.";
                            return View();
                        }
                    }
                    #endregion

                    //Validar el rol del usuario para mostrar o no datos
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

        [HttpGet("EliminarAsignacionTarea/{id}/{idColaborador}")]
        public async Task<ActionResult> EliminarAsignacionTarea(int id, int idColaborador)
        {
            string Token = string.Empty;

            if (HttpContext.Session.GetString("Usuario") != null)
            {
                Token = HttpContext.Session.GetString("Token");
            }

            using (HttpClient clientC = new HttpClient())
            {
                clientC.BaseAddress = new Uri(baseUrl);
                clientC.DefaultRequestHeaders.Accept.Clear();
                clientC.DefaultRequestHeaders.Accept.Add(
                    new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                if (!string.IsNullOrEmpty(Token))
                {
                    clientC.DefaultRequestHeaders.Authorization =
                        new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", Token);
                }

                //Petición GET
                HttpResponseMessage responseC = await clientC.DeleteAsync($"api/TareasyAsignaciones/EliminarAsignacionesId/IdTarea/{id}/IdColaborador/{idColaborador}");

                if (responseC.IsSuccessStatusCode)
                {
                    ViewBag.Error = "Borrado con éxito.";
                }
                else
                {
                    ViewBag.Error = "Error al cargar los datos delos colaboradores asignados a la tarea.";
                }
            }

            return RedirectToAction("DetalleTarea", new { id = id });
        }

        public async Task<IActionResult> GuardarDetalleTarea(ClassDetalleTarea obj)
        {
            string Token = string.Empty;

            if (HttpContext.Session.GetString("Usuario") != null)
            {
                Token = HttpContext.Session.GetString("Token");
            }

            #region GuardarTarea
            if (obj.Id == null && obj.Actividad == null)
            {
                return View();
            }

            string mensaje = null;
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

                UpdateTarea datos = new UpdateTarea
                {
                    idTarea = obj.Id,
                    nombre = obj.Actividad,
                    descripcion = obj.Descripcion,
                    estadoTarea = obj.EstadoTarea,
                    fechaInicio = obj.FechaInicio,
                    fechaFin = obj.FechaFin
                };

                var json = JsonConvert.SerializeObject(datos);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PostAsync("api/TareasyAsignaciones/TareaUpdate", content);

                if (response.IsSuccessStatusCode)
                {
                    string result = await response.Content.ReadAsStringAsync();

                    //Deserializar el JSON que regresa el API
                    dynamic jsonResp = JsonConvert.DeserializeObject(result);
                    mensaje += "Tarea actualizada";
                }
                else
                {
                    ViewBag.Error = "Error al conectar con el servidor.";
                    return View();
                }
            }
            #endregion

            #region Agregar asignacion de Colaborador
            if (obj.IdColaboradorSeleccionado != 0) 
            {
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

                    UpdateAsignacion datos = new UpdateAsignacion
                    {
                        idColaborador = obj.IdColaboradorSeleccionado,
                        idTarea = obj.Id
                    };

                    var json = JsonConvert.SerializeObject(datos);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PutAsync("api/TareasyAsignaciones/AsignacionTareaCreate", content);

                    if (response.IsSuccessStatusCode)
                    {
                        string result = await response.Content.ReadAsStringAsync();

                        //Deserializar el JSON que regresa el API
                        dynamic jsonResp = JsonConvert.DeserializeObject(result);
                        mensaje += "Colaborador asignado";
                    }
                    else
                    {
                        ViewBag.Error = "Error al conectar con el servidor.";
                        return View();
                    }
                }
            }
            #endregion

            return RedirectToAction("DetalleTarea", new { id = obj.Id });
        }
    }
}
