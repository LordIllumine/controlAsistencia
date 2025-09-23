using ApiControlTiempo.Class;
using Microsoft.Data.SqlClient;
using System.Data;
using static ApiControlTiempo.Class.ClassDescansos;
using static ApiControlTiempo.Class.ClassGestionColaboradores;
using static ApiControlTiempo.Class.ClassPermisos;

namespace ApiControlTiempo.Connection
{
    public class ConnectionPermisos
    {
        private DateTime thisDay;

        ClassLogsFile logsFile = new ClassLogsFile();
        private readonly string _schema;

        public ConnectionPermisos(IConfiguration configuration)
        {
            _schema = configuration["Schema:_schema"];
            // También podrías usar: configuration.GetSection("Schema")["_schema"]
        }
        public ClassPermiso_Solicitar Connec_Permiso_Solicitar(ClassPermiso_Solicitar obj)
        {
            thisDay = DateTime.Now;
            string Mensaje = string.Empty;
            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                ClassPermiso_Solicitar resp = new ClassPermiso_Solicitar();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Permiso_Solicitar";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    cmd.Parameters.AddWithValue("@fechaInicio", obj.fechaInicio);
                    cmd.Parameters.AddWithValue("@fechaFin", obj.fechaFin);
                    cmd.Parameters.AddWithValue("@motivo", obj.motivo);

                    // Parámetros de salida
                    var pidPermiso = new SqlParameter("@idPermiso", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pidPermiso);
                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto de autenticación
                    resp.idColaborador = obj.idColaborador;
                    resp.fechaInicio = obj.fechaInicio;
                    resp.fechaFin = obj.fechaFin;
                    resp.motivo = obj.motivo;
                    resp.idPermiso = pidPermiso == null ? 0 : Convert.ToInt32(pidPermiso.Value.ToString());
                    resp.mensaje = pMensaje.Value.ToString();
                }

                return resp;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_Permiso_Solicitar "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_EditarPermiso_Solicitar(ClassEditarPermiso_Solicitar obj)
        {
            thisDay = DateTime.Now;
            string Mensaje = string.Empty;
            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                ClassEditarPermiso_Solicitar resp = new ClassEditarPermiso_Solicitar();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Permiso_Solicitar_update";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idPermiso", obj.idPermiso);
                    cmd.Parameters.AddWithValue("@nuevoEstado", obj.nuevoEstado);

                    // Parámetros de salida
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto de autenticación
                   Mensaje = pMensaje.Value.ToString();
                }

                return Mensaje;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_EditarPermiso_Solicitar "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassPermiso_List_Resp> Connec_PermisoList(ClassPermiso_List obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassPermiso_List_Resp> List = new List<ClassPermiso_List_Resp>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Permiso_List";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    cmd.Parameters.AddWithValue("@estado", obj.estado);
                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return List;

                        // Cachear índices de columnas
                        int idxIdPermiso = reader.GetOrdinal("IDPERMISO");
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxFechaSolicitud = reader.GetOrdinal("FECHASOLICITUD");
                        int idxFechaInicio = reader.GetOrdinal("FECHAINICIO");
                        int idxFechaFin = reader.GetOrdinal("FECHAFIN");
                        int idxMotivo = reader.GetOrdinal("MOTIVO");
                        int idxEstado = reader.GetOrdinal("ESTADO");
                        int idxFechaCreacion = reader.GetOrdinal("FECHA_CREACION");
                        int idxFechaActualizacion = reader.GetOrdinal("FECHA_ACTUALIZACION");

                        while (reader.Read())
                        {
                            try
                            {
                                var objList = new ClassPermiso_List_Resp
                                {
                                    idPermiso = !reader.IsDBNull(idxIdPermiso) ? reader.GetInt32(idxIdPermiso) : 0,
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,
                                    fechaSolicitud = !reader.IsDBNull(idxFechaSolicitud)
                                                       ? reader.GetDateTime(idxFechaSolicitud)
                                                       : (DateTime?)null,
                                    fechaInicio = !reader.IsDBNull(idxFechaInicio)
                                                       ? reader.GetDateTime(idxFechaInicio)
                                                       : (DateTime?)null,
                                    fechaFin = !reader.IsDBNull(idxFechaFin)
                                                       ? reader.GetDateTime(idxFechaFin)
                                                       : (DateTime?)null,
                                    Motivo = !reader.IsDBNull(idxMotivo) ? reader.GetString(idxMotivo) : "",
                                    Estado = !reader.IsDBNull(idxEstado) ? reader.GetString(idxEstado) : "",
                                    fechaCreacion = !reader.IsDBNull(idxFechaCreacion)
                                                       ? reader.GetDateTime(idxFechaCreacion)
                                                       : (DateTime?)null,
                                    fechaActualizacion = !reader.IsDBNull(idxFechaActualizacion)
                                                       ? reader.GetDateTime(idxFechaActualizacion)
                                                       : (DateTime?)null
                                };

                                List.Add(objList);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_PermisoList: "
                                                   + rowEx.Message + " "
                                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                                // Puedes decidir: continuar con las demás filas o lanzar excepción
                                continue;
                            }
                        }
                    }
                }

                return List;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\nError en Connec_PermisoList "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

    }
}
