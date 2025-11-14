using Microsoft.Data.SqlClient;
using static ApiControlTiempo.Class.ClassGestionColaboradores;
using System.Data;
using ApiControlTiempo.Class;

namespace ApiControlTiempo.Connection
{
    public class ConnectionControlAsistencia
    {
        private DateTime thisDay;

        ClassLogsFile logsFile = new ClassLogsFile();
        private readonly string _schema;

        public ConnectionControlAsistencia(IConfiguration configuration)
        {
            _schema = configuration["Schema:_schema"];
            // También podrías usar: configuration.GetSection("Schema")["_schema"]
        }

        public string Connec_AsistenciaEditarRegistro(ClassControlAsistencia obj)
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

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Asistencia_EditarRegistro";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idRegistro", obj.idRegistro);

                    // Convierte los strings a TimeSpan si no son nulos/vacíos
                    if (!string.IsNullOrEmpty(obj.horaEntrada))
                        cmd.Parameters.AddWithValue("@horaEntrada", TimeSpan.Parse(obj.horaEntrada));
                    else
                        cmd.Parameters.AddWithValue("@horaEntrada", DBNull.Value);

                    if (!string.IsNullOrEmpty(obj.horaSalida))
                        cmd.Parameters.AddWithValue("@horaSalida", TimeSpan.Parse(obj.horaSalida));
                    else
                        cmd.Parameters.AddWithValue("@horaSalida", DBNull.Value);

                    // Parámetros de salida
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pMensaje);

                    cmd.ExecuteNonQuery();

                    Mensaje = pMensaje.Value?.ToString();
                }

                return Mensaje;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_AsistenciaEditarRegistro "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassControlAsistenciaResp> Connec_Asistencia_GetByRango(ClassControlAsistenciaGetByRango obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassControlAsistenciaResp> Listcolaborador = new List<ClassControlAsistenciaResp>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Asistencia_GetByRango";
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return Listcolaborador;

                        // Cachear índices de columnas
                        int idxIdRegistro = reader.GetOrdinal("IDREGISTRO");
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxFecha = reader.GetOrdinal("FECHA");
                        int idxHoraEntrada = reader.GetOrdinal("HORAENTRADA");
                        int idxIpRegistro = reader.GetOrdinal("IPREGISTRO");
                        int idxMacAddress = reader.GetOrdinal("MACADDRESS");
                        int idxFechaCreacion = reader.GetOrdinal("FECHA_CREACION");
                        int idxFechaActualizacion = reader.GetOrdinal("FECHA_ACTUALIZACION");

                        while (reader.Read())
                        {
                            try
                            {
                                var objColaborador = new ClassControlAsistenciaResp
                                {
                                    idRegistro = !reader.IsDBNull(idxIdRegistro) ? reader.GetInt32(idxIdRegistro) : 0,
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,

                                    fecha = !reader.IsDBNull(idxFecha)
                                              ? DateOnly.FromDateTime(reader.GetDateTime(idxFecha))
                                              : (DateOnly?)null,

                                    horaEntrada = !reader.IsDBNull(idxHoraEntrada)
                                                    ? reader.GetFieldValue<TimeSpan>(idxHoraEntrada)
                                                    : (TimeSpan?)null,

                                    IPREGISTRO = !reader.IsDBNull(idxIpRegistro) ? reader.GetString(idxIpRegistro) : null,
                                    MACADDRESS = !reader.IsDBNull(idxMacAddress) ? reader.GetString(idxMacAddress) : null,

                                    fecha_Creacion = !reader.IsDBNull(idxFechaCreacion)
                                                       ? reader.GetDateTime(idxFechaCreacion)
                                                       : (DateTime?)null,

                                    fecha_Actualizacion = !reader.IsDBNull(idxFechaActualizacion)
                                                            ? reader.GetDateTime(idxFechaActualizacion)
                                                            : (DateTime?)null
                                };

                                Listcolaborador.Add(objColaborador);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Asistencia_GetByRango: "
                                                   + rowEx.Message + " "
                                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                                // Puedes decidir: continuar con las demás filas o lanzar excepción
                                continue;
                            }
                        }
                    }
                }

                return Listcolaborador;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\nError en Connec_Asistencia_GetByRango "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassAsistenciaHoras> Connec_Asistencia_Horas(ClassControlAsistenciaGetByRango obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassAsistenciaHoras> Listcolaborador = new List<ClassAsistenciaHoras>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Asistencia_ResumenHoras";
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return Listcolaborador;

                        // Cachear índices de columnas
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxMinutosTrabajados = reader.GetOrdinal("MINUTOS_TRABAJADOS");                      

                        while (reader.Read())
                        {
                            try
                            {
                                var objColaborador = new ClassAsistenciaHoras
                                {
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,
                                    minutosTrabajados = !reader.IsDBNull(idxMinutosTrabajados) ? reader.GetInt32(idxMinutosTrabajados) : 0
                                };

                                Listcolaborador.Add(objColaborador);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Asistencia_Horas: "
                                                   + rowEx.Message + " "
                                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                                // Puedes decidir: continuar con las demás filas o lanzar excepción
                                continue;
                            }
                        }
                    }
                }

                return Listcolaborador;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\nError en Connec_Asistencia_Horas "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_Asistencia_MarcarEntrada(ClassAsistenciaMarcarEntrada obj)
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

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Asistencia_MarcarEntrada";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    //cmd.Parameters.AddWithValue("@fecha", DateOnly.FromDateTime(Convert.ToDateTime(obj.fecha)));

                    //// Convierte los strings a TimeSpan si no son nulos/vacíos
                    //if (!string.IsNullOrEmpty(obj.horaEntrada))
                    //    cmd.Parameters.AddWithValue("@horaEntrada", TimeSpan.Parse(obj.horaEntrada));
                    //else
                    //    cmd.Parameters.AddWithValue("@horaEntrada", DBNull.Value);
                    
                    cmd.Parameters.AddWithValue("@ip", obj.ip);
                    cmd.Parameters.AddWithValue("@mac", obj.mac);

                    // Parámetros de salida
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pMensaje);
                    cmd.ExecuteNonQuery();

                    Mensaje = pMensaje.Value?.ToString();
                }

                return Mensaje;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_Asistencia_MarcarEntrada "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_Asistencia_MarcarSalida(ClassAsistenciaMarcarSalida obj)
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

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Asistencia_MarcarSalida";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    //cmd.Parameters.AddWithValue("@fecha", DateOnly.FromDateTime(Convert.ToDateTime(obj.fecha)));

                    //// Convierte los strings a TimeSpan si no son nulos/vacíos
                    //if (!string.IsNullOrEmpty(obj.horaSalida))
                    //    cmd.Parameters.AddWithValue("@horaSalida", TimeSpan.Parse(obj.horaSalida));
                    //else
                    //    cmd.Parameters.AddWithValue("@horaSalida", DBNull.Value);

                    // Parámetros de salida
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pMensaje);

                    cmd.ExecuteNonQuery();

                    Mensaje = pMensaje.Value?.ToString();
                }

                return Mensaje;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_Asistencia_MarcarSalida "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }
    }
}
