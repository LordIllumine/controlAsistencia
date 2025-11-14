using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.Elfie.Serialization;
using Newtonsoft.Json;
using NuGet.Common;
using System.Diagnostics;
using System.Net;
using System.Reflection;
using System.Text;
using webControlAsistencia.Models;
using static System.Runtime.InteropServices.JavaScript.JSType;
using Microsoft.AspNetCore.Mvc.Filters;
using webControlAsistencia.Filters;

namespace webControlAsistencia.Controllers
{
    // Para usarlo en tu controlador protegido:
    public class HomeController : Controller
    {
        public static string IdColaborador;
        public static string Usuario;
        public static string Rol;
        public static string Token;

        private readonly ILogger<HomeController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;
        public string? ClientIP { get; set; }

        public HomeController(ILogger<HomeController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        [HttpGet]
        public IActionResult Index()
        {
            // No enviar modelo con errores
            return View();
        }

        //Este es el Login 
        [HttpPost]
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

                        // Session para mantenerlo por más tiempo
                        HttpContext.Session.SetString("IdColaborador", datos.IdColaborador.ToString());
                        HttpContext.Session.SetString("Usuario", datos.Usuario);
                        HttpContext.Session.SetString("Rol", datos.Rol);
                        HttpContext.Session.SetString("Token", datos.Token);

                        #region subir ip y macaddres
                        using (HttpClient clientIP = new HttpClient())
                        {
                            clientIP.BaseAddress = new Uri(baseUrl);
                            clientIP.DefaultRequestHeaders.Accept.Clear();
                            clientIP.DefaultRequestHeaders.Accept.Add(
                                new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                            if (!string.IsNullOrEmpty(datos.Token))
                            {
                                clientIP.DefaultRequestHeaders.Authorization =
                                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", datos.Token);
                            }

                            //Recuperar la IP del usuario
                            ConsultarIP();

                            var datosIP = new
                            {
                                idColaborador = datos.IdColaborador,
                                ip = ClientIP, 
                                mac = "No se puso consultar el MacAddres"
                            };

                            var jsonIP = JsonConvert.SerializeObject(datosIP);
                            var contentIP = new StringContent(jsonIP, Encoding.UTF8, "application/json");

                            HttpResponseMessage responseIP = await clientIP.PutAsync("api/ControlAsistencia/AsistenciaMarcarEntrada", contentIP);

                            if (responseIP.IsSuccessStatusCode)
                            {
                                string resultIP = await responseIP.Content.ReadAsStringAsync();
                                
                                ////Deserializar el JSON que regresa el API
                                //DescansoApi jsonResp = JsonConvert.DeserializeObject<DescansoApi>(result);

                                //ObjResp.ListDescanso = jsonResp.Listar;
                                return RedirectToAction("Principal", "Principal");
                            }
                            else
                            {
                                ViewBag.Error = "Error al conectar con el servidor.";
                                return View();
                            }
                        }
                        #endregion

                        //return RedirectToAction("Principal", "Principal");
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

        public async Task<IActionResult> MarcarSalida()
        {
            if (HttpContext.Session.GetString("Usuario") != null)
            {
                IdColaborador = HttpContext.Session.GetString("IdColaborador");
                Usuario = HttpContext.Session.GetString("Usuario");
                Rol = HttpContext.Session.GetString("Rol");
                Token = HttpContext.Session.GetString("Token");
            }

            #region subir ip y macaddres
            using (HttpClient clientIP = new HttpClient())
            {
                clientIP.BaseAddress = new Uri(baseUrl);
                clientIP.DefaultRequestHeaders.Accept.Clear();
                clientIP.DefaultRequestHeaders.Accept.Add(
                    new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                if (!string.IsNullOrEmpty(Token))
                {
                    clientIP.DefaultRequestHeaders.Authorization =
                        new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", Token);
                }

                //Recuperar la IP del usuario
                ConsultarIP();

                var datosIP = new
                {
                    idColaborador = IdColaborador,
                };

                var jsonIP = JsonConvert.SerializeObject(datosIP);
                var contentIP = new StringContent(jsonIP, Encoding.UTF8, "application/json");

                HttpResponseMessage responseIP = await clientIP.PostAsync("api/ControlAsistencia/AsistenciaMarcarSalida", contentIP);

                if (responseIP.IsSuccessStatusCode)
                {
                    string resultIP = await responseIP.Content.ReadAsStringAsync();

                    // Elimina la variable de sesión 'IdColaborador'
                    HttpContext.Session.Remove("IdColaborador");
                    // Elimina la variable de sesión 'Usuario'
                    HttpContext.Session.Remove("Usuario");
                    // Elimina la variable de sesión 'Rol'
                    HttpContext.Session.Remove("Rol");
                    // Elimina la variable de sesión 'Token'
                    HttpContext.Session.Remove("Token");
                    // Elimina todas las claves y valores almacenados en la sesión actual
                    HttpContext.Session.Clear();

                    ////Deserializar el JSON que regresa el API
                    //DescansoApi jsonResp = JsonConvert.DeserializeObject<DescansoApi>(result);

                    //ObjResp.ListDescanso = jsonResp.Listar;
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    ViewBag.Error = "Error al conectar con el servidor.";
                    return View();
                }
            }
            #endregion
        }

        public void ConsultarIP()
        {
            // 1. Obtener la IP del cliente
            // HttpContext.Connection.RemoteIpAddress proporciona el objeto IPAddress
            IPAddress? remoteIpAddress = HttpContext.Connection.RemoteIpAddress;

            if (remoteIpAddress != null)
            {
                // Opcional: Si está en IPv6 mapeado, convertir a IPv4 para mejor lectura
                if (remoteIpAddress.IsIPv4MappedToIPv6)
                {
                    remoteIpAddress = remoteIpAddress.MapToIPv4();
                }

                // Asignar a la variable pública para mostrarla en la vista
                ClientIP = remoteIpAddress.ToString();
            }
            else
            {
                ClientIP = "IP no disponible";
            }
        }

        public IActionResult OlvidoContrasena(ClassResetPassword obj)
        {
            if (obj.Correo == null)
            {
                return View();
            }
            else 
            {
                return RedirectToAction("ValidoToken", "Home");
            }
        }

        public IActionResult ValidoToken(ClassValidoToken obj)
        {

            return View();
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
