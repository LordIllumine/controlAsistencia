using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.Elfie.Serialization;
using Newtonsoft.Json;
using System.Text;
using webControlAsistencia.Filters;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    [SessionAuthorize]
    public class ColaboradorController : Controller
    {
        public static string IdColaborador;
        public static string Usuario;
        public static string Rol;
        public static string Token;
        public static string Mensaje;

        private readonly ILogger<ColaboradorController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;


        public ColaboradorController(ILogger<ColaboradorController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        public async Task<IActionResult> ListarColaboradores()
        {
            // Recuperar los datos que vienen del login
            string IdColaborador = string.Empty;
            string Usuario = string.Empty;
            string Rol = string.Empty;
            string Token = string.Empty;
            Mensaje = null;

            if (HttpContext.Session.GetString("Usuario") != null)
            {
                IdColaborador = HttpContext.Session.GetString("IdColaborador");
                Usuario = HttpContext.Session.GetString("Usuario");
                Rol = HttpContext.Session.GetString("Rol");
                Token = HttpContext.Session.GetString("Token");
            }

            List<ClassColaborador>? ObjResp = new List<ClassColaborador>();
            //ClassPermiso_List listarPermiso = new ClassPermiso_List();

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

                var datos = new
                {
                    idColaborador = IdColaborador                    
                };
                //texto = null,
                //rol = null,
                //estado = null

                var json = JsonConvert.SerializeObject(datos);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PostAsync("api/GestionColaboradores/ConsultarColaboradorFiltro", content);

                if (response.IsSuccessStatusCode)
                {
                    string result = await response.Content.ReadAsStringAsync();

                    //Deserializar el JSON que regresa el API
                    ClassColaboradorAList jsonResp = JsonConvert.DeserializeObject<ClassColaboradorAList>(result);

                    ObjResp = jsonResp.resp;
                }
                else
                {
                    ViewBag.Error = "Error al conectar con el servidor.";
                    return View();
                }
            }

            //Validar el rol del usuario para mostrar o no datos
            if (!string.IsNullOrEmpty(Rol) && Rol.Equals("Administrador"))
            {
                ViewBag.Validar = "1"; //Lo hago con números por seguridad, de esta manera el inspeccionar no mostrara el dato del rol
            }
            else
            {
                ViewBag.Validar = "0";
            }

            return View(ObjResp);
            
        }

        public async Task<IActionResult> CrearColaborador(ClassColaboradorCrear obj)
        {
            try
            {
                ViewBag.Message = null;
                
                if (HttpContext.Session.GetString("Usuario") != null)
                {
                    IdColaborador = HttpContext.Session.GetString("IdColaborador");
                    Usuario = HttpContext.Session.GetString("Usuario");
                    Rol = HttpContext.Session.GetString("Rol");
                    Token = HttpContext.Session.GetString("Token");
                }

                if (!string.IsNullOrEmpty(obj.Correo) && !string.IsNullOrEmpty(obj.Contraseña)) 
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

                        var json = JsonConvert.SerializeObject(obj);

                        var content = new StringContent(json, Encoding.UTF8, "application/json");

                        HttpResponseMessage response = await client.PutAsync("api/GestionColaboradores/CrearColaborador", content);

                        if (response.IsSuccessStatusCode)
                        {
                            string result = await response.Content.ReadAsStringAsync();

                            //Deserializar el objeto completo que contiene listTareas y message
                            ClassColaboradorRestCreate jsonResp =
                                JsonConvert.DeserializeObject<ClassColaboradorRestCreate>(result);

                            ViewBag.Message = jsonResp.message;
                            
                            return View();
                        }
                        else
                        {
                            ViewBag.Message = "hubo un problema al crear el colaborador";

                            return View();
                        }
                    }
                }
            }
            catch (Exception)
            {

                throw;
            }

            return View();
        }

        [HttpGet("ActualizarColaborador/{idColaborador}")]
        public async Task<IActionResult> ActualizarColaborador(int idColaborador)
        {
            try
            {
                ViewBag.Message = null;
                if (!string.IsNullOrEmpty(Mensaje)) 
                { 
                    ViewBag.Message = Mensaje;
                    Mensaje = null;
                }
                if (HttpContext.Session.GetString("Usuario") != null)
                {
                    IdColaborador = HttpContext.Session.GetString("IdColaborador");
                    Usuario = HttpContext.Session.GetString("Usuario");
                    Rol = HttpContext.Session.GetString("Rol");
                    Token = HttpContext.Session.GetString("Token");
                }

                if (idColaborador != 0 && idColaborador != null) 
                {
                    ClassColaboradorID objColaborador = new ClassColaboradorID();
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
                        HttpResponseMessage responseC = await clientC.GetAsync($"api/GestionColaboradores/ConsultaColaboradorIDEspecifico/{idColaborador}");

                        if (responseC.IsSuccessStatusCode)
                        {
                            var resultC = await responseC.Content.ReadAsStringAsync();
                            // Deserializar el objeto completo 
                            ClassColaboradorIDMain jsonRespC = JsonConvert.DeserializeObject<ClassColaboradorIDMain>(resultC);
                            objColaborador = jsonRespC.objJson;

                            return View(objColaborador);
                        }
                        else
                        {
                            ViewBag.Error = "Error al cargar los datos del colaborador.";
                            return View();
                        }
                    }
                }
            }
            catch (Exception)
            {

                throw;
            }

            return View();
        }

        public async Task<IActionResult> ActualizarColaboradorEjecutar(ClassColaboradorID obj)
        {
            try
            {
                Mensaje = null;

                if (HttpContext.Session.GetString("Usuario") != null)
                {
                    IdColaborador = HttpContext.Session.GetString("IdColaborador");
                    Usuario = HttpContext.Session.GetString("Usuario");
                    Rol = HttpContext.Session.GetString("Rol");
                    Token = HttpContext.Session.GetString("Token");
                }

                if (obj.IdColaborador != 0 && obj.IdColaborador != null)
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

                        var json = JsonConvert.SerializeObject(obj);

                        var content = new StringContent(json, Encoding.UTF8, "application/json");

                        HttpResponseMessage response = await client.PostAsync("api/GestionColaboradores/ActualizarColaborador", content);

                        if (response.IsSuccessStatusCode)
                        {
                            string result = await response.Content.ReadAsStringAsync();

                            //Deserializar el objeto completo que contiene listTareas y message
                            ClassColaboradorRestCreate jsonResp =
                                JsonConvert.DeserializeObject<ClassColaboradorRestCreate>(result);

                            Mensaje = jsonResp.message;

                            return RedirectToAction("ActualizarColaborador", new { idColaborador = IdColaborador });
                        }
                        else
                        {
                            Mensaje = "hubo un problema al crear el colaborador";

                            return RedirectToAction("ActualizarColaborador", new { idColaborador = obj.IdColaborador });
                        }
                    }
                }
            }
            catch (Exception)
            {

                throw;
            }

            return View();
        }

    }
}
