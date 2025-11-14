using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Text;
using webControlAsistencia.Filters;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    [SessionAuthorize]
    public class SolicitarDescansoController : Controller
    {
        public static string IdColaborador;
        public static string Usuario;
        public static string Rol;
        public static string Token;
        public static string Mensaje;

        private readonly ILogger<SolicitarDescansoController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;

        public SolicitarDescansoController(ILogger<SolicitarDescansoController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        public async Task<IActionResult> SolicitarDescanso(string filtro, DateTime? fechaInicioD, DateTime? fechaFinD)
        {
            try
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

                ClassDescanso ObjResp = new ClassDescanso();
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

                    if (filtro == "Todos")
                    {
                        filtro = null;
                    }

                    string fechaInicioISO = null;
                    string fechaFinISO = null;

                    if (fechaInicioD.HasValue)
                    {
                        var fechaInicioAjustada = new DateTime(fechaInicioD.Value.Year, fechaInicioD.Value.Month, fechaInicioD.Value.Day, 0, 0, 0, 0, DateTimeKind.Local);
                        fechaInicioISO = fechaInicioAjustada.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                    }

                    if (fechaFinD.HasValue)
                    {
                        var fechaFinAjustada = new DateTime(fechaFinD.Value.Year, fechaFinD.Value.Month, fechaFinD.Value.Day, 23, 59, 59, 999, DateTimeKind.Local);
                        fechaFinISO = fechaFinAjustada.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                    }

                    //ClassPermiso datos = new ClassPermiso();
                    //datos.idColaborador = Convert.ToInt32(IdColaborador);
                    //datos.estado = filtro;
                    //datos.desde = fechaInicioISO;
                    //datos.hasta = fechaFinISO;

                    var datos = new
                    {
                        idColaborador = IdColaborador,
                        tipoDescanso = filtro,
                        fechaInicio = fechaInicioISO,
                        fechaFin = fechaFinISO
                    };

                    var json = JsonConvert.SerializeObject(datos);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PostAsync("api/Descansos/ListarDescansos", content);

                    if (response.IsSuccessStatusCode)
                    {
                        string result = await response.Content.ReadAsStringAsync();

                        //Deserializar el JSON que regresa el API
                        DescansoApi jsonResp = JsonConvert.DeserializeObject<DescansoApi>(result);

                        ObjResp.ListDescanso = jsonResp.Listar;
                    }
                    else
                    {
                        ViewBag.Error = "Error al conectar con el servidor.";
                        return View(ObjResp);
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

                }
                return View(ObjResp);
            }
            catch (Exception ex)
            {
                DescansoApi objCatch = new DescansoApi();
                return View(objCatch);
            }
        }

        public async Task<IActionResult> IniciarDescanso(ClassDescanso obj)
        {
            try
            {
                // Recuperar los datos que vienen del login
                string IdColaborador = string.Empty;
                string Usuario = string.Empty;
                string Rol = string.Empty;
                string Token = string.Empty;
                string Mensaje = string.Empty;

                if (HttpContext.Session.GetString("Usuario") != null)
                {
                    IdColaborador = HttpContext.Session.GetString("IdColaborador");
                    Usuario = HttpContext.Session.GetString("Usuario");
                    Rol = HttpContext.Session.GetString("Rol");
                    Token = HttpContext.Session.GetString("Token");
                }

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
                        idColaborador = IdColaborador,
                        tipoDescanso = obj.TipoDescansos
                    };

                    var json = JsonConvert.SerializeObject(datos);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PostAsync("api/Descansos/Descanso_Iniciar", content);

                    if (response.IsSuccessStatusCode)
                    {
                        string result = await response.Content.ReadAsStringAsync();

                        //Deserializar el JSON que regresa el API
                        IniciarDescansoResp jsonResp = JsonConvert.DeserializeObject<IniciarDescansoResp>(result);

                        Mensaje = jsonResp.Resp.Mensaje;
                    }
                    else
                    {
                        ViewBag.Error = Mensaje;
                        return RedirectToAction("SolicitarDescanso", new { filtro = (string)null, fechaInicioD = (string)null, fechaFinD = (string)null });
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

                }
                return RedirectToAction("SolicitarDescanso", new { filtro = (string)null, fechaInicioD = (string)null, fechaFinD = (string)null });
            }
            catch (Exception ex)
            {
                DescansoApi objCatch = new DescansoApi();
                return View(objCatch);
            }
        }
    }
}
