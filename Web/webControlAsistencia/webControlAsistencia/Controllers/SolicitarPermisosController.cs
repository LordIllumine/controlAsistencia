using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.Elfie.Serialization;
using Newtonsoft.Json;
using System.Text;
using webControlAsistencia.Filters;
using webControlAsistencia.Models;

namespace webControlAsistencia.Controllers
{
    [SessionAuthorize]
    public class SolicitarPermisosController : Controller
    {
        public static string IdColaborador;
        public static string Usuario;
        public static string Rol;
        public static string Token;
        public static string Mensaje;

        private readonly ILogger<SolicitarPermisosController> _logger;
        private readonly IConfiguration _configuration;
        public static string baseUrl = string.Empty;


        public SolicitarPermisosController(ILogger<SolicitarPermisosController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            baseUrl = _configuration["VariablesGlobales:ApiUrl"];
        }

        public async Task<IActionResult> SolicitarPermisos(string filtro, DateTime? fechaInicioP, DateTime? fechaFinP)
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

                ClassSolicitarPermisos ObjResp = new ClassSolicitarPermisos();
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

                    if (fechaInicioP.HasValue)
                    {
                        var fechaInicioAjustada = new DateTime(fechaInicioP.Value.Year, fechaInicioP.Value.Month, fechaInicioP.Value.Day, 0, 0, 0, 0, DateTimeKind.Local);
                        fechaInicioISO = fechaInicioAjustada.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                    }

                    if (fechaFinP.HasValue)
                    {
                        var fechaFinAjustada = new DateTime(fechaFinP.Value.Year, fechaFinP.Value.Month, fechaFinP.Value.Day, 23, 59, 59, 999, DateTimeKind.Local);
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
                        filtro = filtro,
                        desde = fechaInicioISO,
                        hasta = fechaFinISO
                    };

                    var json = JsonConvert.SerializeObject(datos);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PostAsync("api/Permisos/ListarPermisos", content);

                    if (response.IsSuccessStatusCode)
                    {
                        string result = await response.Content.ReadAsStringAsync();

                        //Deserializar el JSON que regresa el API
                        ListarPermisoResponse jsonResp = JsonConvert.DeserializeObject<ListarPermisoResponse>(result);

                        ObjResp.ListPermiso = jsonResp.ListarPermiso;
                    }
                    else
                    {
                        ViewBag.Error = "Error al conectar con el servidor.";
                        return View();
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
                ClassSolicitarPermisos objCatch = new ClassSolicitarPermisos();
                return View(objCatch);
            }
        }

        [HttpGet("DetallesPermisos/{idPermiso}/{idColaborador}")]
        public async Task<IActionResult> DetallesPermisos(int idPermiso, int idColaborador)
        {
            try
            {
                // Recuperar los datos que vienen del login
                string IdColaborador = string.Empty;
                string Usuario = string.Empty;
                string Rol = string.Empty;
                string Token = string.Empty;
                
                ViewBag.Error = Mensaje;

                if (HttpContext.Session.GetString("Usuario") != null)
                {
                    IdColaborador = HttpContext.Session.GetString("IdColaborador");
                    Usuario = HttpContext.Session.GetString("Usuario");
                    Rol = HttpContext.Session.GetString("Rol");
                    Token = HttpContext.Session.GetString("Token");
                }

                ClassPermiso_List Permiso = new ClassPermiso_List();

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
                        idColaborador = idColaborador,
                        idPermiso = idPermiso
                    };

                    var json = JsonConvert.SerializeObject(datos);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PostAsync("api/Permisos/ListarPermisosID", content);

                    if (response.IsSuccessStatusCode)
                    {
                        string result = await response.Content.ReadAsStringAsync();

                        //Deserializar el JSON que regresa el API
                        ListarPermisoResponseID jsonResp = JsonConvert.DeserializeObject<ListarPermisoResponseID>(result);

                        Permiso = jsonResp.ListarPermiso;
                    }
                    else
                    {
                        ViewBag.Error = "Error al conectar con el servidor.";
                        return View();
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

                    Mensaje = string.Empty;
                }
                return View(Permiso);
            }
            catch (Exception ex)
            {
                ClassPermiso_List objCatch = new ClassPermiso_List();
                return View(objCatch);
            }
        }

        public async Task<IActionResult> CambiarEstadoPermiso(ClassPermiso_List Permiso)
        {
            try
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
                        idPermiso = Permiso.IdPermiso,
                        nuevoEstado = Permiso.Estado
                    };

                    var json = JsonConvert.SerializeObject(datos);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PostAsync("api/Permisos/EditarPermiso_Solicitar", content);

                    if (response.IsSuccessStatusCode)
                    {
                        string result = await response.Content.ReadAsStringAsync();

                        ////Deserializar el JSON que regresa el API
                        //ListarPermisoResponseID jsonResp = JsonConvert.DeserializeObject<ListarPermisoResponseID>(result);

                        //Permiso = jsonResp.ListarPermiso;
                        Mensaje = "Actualizado con éxito";
                    }
                    else
                    {
                        Mensaje = "Error al conectar con el servidor.";
                        return View();
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
                return RedirectToAction("DetallesPermisos", new { idPermiso = Permiso.IdPermiso, idColaborador = Permiso.IdColaborador });
            }
            catch (Exception ex)
            {
                ClassPermiso_List objCatch = new ClassPermiso_List();
                return View(objCatch);
            }
        }

        public async Task<IActionResult> CrearPermiso(ClassSolicitarPermisos Permiso)
        {
            try
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

                    if (Permiso.FechaInicio.HasValue)
                    {
                        var fechaInicioAjustada = new DateTime(Permiso.FechaInicio.Value.Year, Permiso.FechaInicio.Value.Month, Permiso.FechaInicio.Value.Day, 0, 0, 0, 0, DateTimeKind.Local);
                        fechaInicioISO = fechaInicioAjustada.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                    }

                    if (Permiso.FechaFin.HasValue)
                    {
                        var fechaFinAjustada = new DateTime(Permiso.FechaFin.Value.Year, Permiso.FechaFin.Value.Month, Permiso.FechaFin.Value.Day, 23, 59, 59, 999, DateTimeKind.Local);
                        fechaFinISO = fechaFinAjustada.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                    }

                    var datos = new
                    {
                        idColaborador = Convert.ToInt32(IdColaborador),
                        fechaInicio = fechaInicioISO,
                        fechaFin = fechaFinISO,
                        Asunto = Permiso.TipoPermiso,
                        motivo = Permiso.TipoPermiso,
                        descripcion = Permiso.Descripcion
                    };

                    var json = JsonConvert.SerializeObject(datos);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PutAsync("api/Permisos/Permiso_Solicitar", content);

                    if (response.IsSuccessStatusCode)
                    {
                        string result = await response.Content.ReadAsStringAsync();

                        ////Deserializar el JSON que regresa el API
                        //ListarPermisoResponseID jsonResp = JsonConvert.DeserializeObject<ListarPermisoResponseID>(result);

                        //Permiso = jsonResp.ListarPermiso;
                        Mensaje = "Creado con éxito";
                    }
                    else
                    {
                        Mensaje = "Error al conectar con el servidor.";
                        
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
                return RedirectToAction("SolicitarPermisos", new { filtro = (string)null, fechaInicioP = (string)null, fechaFinP = (string)null });
            }
            catch (Exception ex)
            {
                ClassPermiso_List objCatch = new ClassPermiso_List();
                return View(objCatch);
            }
        }
    }
}
