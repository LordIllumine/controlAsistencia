using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class ActividadesAsignadasController : Controller
    {
        public static string IdColaborador;
        public static string Usuario;
        public static string Rol;
        public static string Token;

        private readonly ILogger<ActividadesAsignadasController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;


        public ActividadesAsignadasController(ILogger<ActividadesAsignadasController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        public async Task<IActionResult> ActividadesAsignadas(string filtro, DateTime? fechaInicio, DateTime? fechaFin)
        {
            // Recuperar los datos que vienen del login
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

                string fechaini = DateTime.Parse("1/10/2024 12:00:00 AM");
                string formatoISO = fecha.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");

                var obj = new
                {
                    filtro = filtro,
                    fechaIniTarea = fechaInicio ,
                    fechafinTarea = fechaFin,
                    idColaborador = IdColaborador
                };

                //fecha = DateTime.Parse("1/10/2024 12:00:00 AM");
                //string formatoISO = fecha.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");

                var json = JsonConvert.SerializeObject(obj);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PostAsync("api/TareasyAsignaciones/TareaList", content);

                if (response.IsSuccessStatusCode)
                {
                    string result = await response.Content.ReadAsStringAsync();

                    //Deserializar el JSON que regresa el API
                    List<ClassActividadesAsignadas> jsonResp = JsonConvert.DeserializeObject<List<ClassActividadesAsignadas>>(result);
                    return View(jsonResp);
                }
                else
                {
                    var model = new ClassActividadesAsignadasViewModel
                    {
                        listTareas = new List<ClassActividadesAsignadas>()
                    };

                    return View(model);
                }
            }
            
        }
    }
}
