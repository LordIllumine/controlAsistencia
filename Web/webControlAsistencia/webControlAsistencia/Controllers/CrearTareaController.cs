using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.Elfie.Serialization;
using Newtonsoft.Json;
using System.Text;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class CrearTareaController : Controller
    {
        public static string IdColaborador;
        public static string Usuario;
        public static string Rol;
        public static string Token;

        private readonly ILogger<CrearTareaController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;

        public CrearTareaController(ILogger<CrearTareaController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        public async Task<IActionResult> CrearTarea(ClassCrearTarea objCreaTarea)
        {
            if (string.IsNullOrEmpty(objCreaTarea.Tarea) && string.IsNullOrEmpty(objCreaTarea.Descripcion))         
            {
                return View();
            }

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

                var json = JsonConvert.SerializeObject(objCreaTarea, new JsonSerializerSettings
                {
                    DateFormatString = "yyyy-MM-ddTHH:mm:ss.fffZ",
                    DateTimeZoneHandling = DateTimeZoneHandling.Utc
                });

                var content = new StringContent(json, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PutAsync("api/TareasyAsignaciones/TareaCreate", content);

                if (response.IsSuccessStatusCode)
                {
                    string result = await response.Content.ReadAsStringAsync();

                    //Deserializar el objeto completo que contiene listTareas y message
                    RootResponse jsonResp =
                        JsonConvert.DeserializeObject<RootResponse>(result);

                    ViewBag.Message = jsonResp.Resp.Mensaje;

                    return View();
                }
                else
                {
                    ViewBag.Message = "hubo un problema al crear la tarea";

                    return View();
                }
            }
        }

    }
}
