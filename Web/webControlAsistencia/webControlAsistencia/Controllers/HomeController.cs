using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Diagnostics;
using System.Reflection;
using System.Text;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;


        public HomeController(ILogger<HomeController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        //Este es el Login 
        public async Task<IActionResult> Index(ClassLogin obj)
        {
            if (obj.usuario == null && obj.contrasena == null)
            {
                return View();
            }

            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new Uri(baseUrl);
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(
                    new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                var json = JsonConvert.SerializeObject(obj);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PostAsync("api/Autentificate/GetToken", content);

                if (response.IsSuccessStatusCode)
                {
                    string result = await response.Content.ReadAsStringAsync();

                    //Deserializar el JSON que regresa el API
                    dynamic jsonResp = JsonConvert.DeserializeObject(result);

                    bool autenticado = jsonResp.resUser.autenticado;
                    if (autenticado)
                    {
                        ClassLoginResp datos = new ClassLoginResp
                        {
                            IdColaborador = jsonResp.resUser.idColaborador,
                            Usuario = jsonResp.resUser.usuario,
                            Rol = jsonResp.resUser.rol,
                            Token = jsonResp.resUser.token
                        };

                        ////Guardar en variables estáticas o en TempData
                        //TempData["Usuario"] = datos.Usuario;
                        //TempData["Rol"] = datos.Rol;
                        //TempData["Token"] = datos.Token;

                        // También podrías usar Session si prefieres mantenerlo por más tiempo
                        HttpContext.Session.SetString("IdColaborador", datos.IdColaborador.ToString());
                        HttpContext.Session.SetString("Usuario", datos.Usuario);
                        HttpContext.Session.SetString("Rol", datos.Rol);
                        HttpContext.Session.SetString("Token", datos.Token);

                        return RedirectToAction("Principal", "Principal");
                    }
                    else
                    {
                        ViewBag.Error = "Usuario o contraseña incorrectos.";
                        return View();
                    }
                }
                else
                {
                    ViewBag.Error = "Error al conectar con el servidor.";
                    return View();
                }
            }
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
