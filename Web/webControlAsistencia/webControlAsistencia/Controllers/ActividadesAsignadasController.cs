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

                string fechaInicioISO = null;
                string fechaFinISO = null;

                if (fechaInicio.HasValue)
                {
                    var fechaInicioAjustada = new DateTime(fechaInicio.Value.Year, fechaInicio.Value.Month, fechaInicio.Value.Day, 0, 0, 0, 0, DateTimeKind.Local);
                    fechaInicioISO = fechaInicioAjustada.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                }

                if (fechaFin.HasValue)
                {
                    var fechaFinAjustada = new DateTime(fechaFin.Value.Year, fechaFin.Value.Month, fechaFin.Value.Day, 23, 59, 59, 999, DateTimeKind.Local);
                    fechaFinISO = fechaFinAjustada.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                }

                var obj = new
                {
                    filtro = filtro,
                    fechaIniTarea = fechaInicioISO,
                    fechafinTarea = fechaFinISO,
                    idColaborador = IdColaborador
                };

                var json = JsonConvert.SerializeObject(obj);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PostAsync("api/TareasyAsignaciones/TareaList", content);

                if (response.IsSuccessStatusCode)
                {
                    string result = await response.Content.ReadAsStringAsync();

                    //Deserializar el objeto completo que contiene listTareas y message
                    ClassActividadesAsignadasViewModel jsonResp =
                        JsonConvert.DeserializeObject<ClassActividadesAsignadasViewModel>(result);

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
