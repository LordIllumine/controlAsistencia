using ApiControlTiempo.Class;
using Microsoft.Data.SqlClient;
using System.Data;
using static ApiControlTiempo.Class.ClassDescansos;
using static ApiControlTiempo.Class.ClassGestionColaboradores;
using static ApiControlTiempo.Class.ClassTareasyAsignaciones;

namespace ApiControlTiempo.Connection
{
    public class ConnectionTareasyAsignaciones
    {
        private DateTime thisDay;

        ClassLogsFile logsFile = new ClassLogsFile();
        private readonly string _schema;

        public ConnectionTareasyAsignaciones(IConfiguration configuration)
        {
            _schema = configuration["Schema:_schema"];
            // También podrías usar: configuration.GetSection("Schema")["_schema"]
        }

        public ClassAsignacion_Create Connec_Asignacion_Create(ClassAsignacion_Create obj)
        {
            thisDay = DateTime.Now;
            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                ClassAsignacion_Create resp = new ClassAsignacion_Create();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Asignacion_Create";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    cmd.Parameters.AddWithValue("@idTarea", obj.idTarea);
                    cmd.Parameters.AddWithValue("@fechaAsignacion", obj.fechaAsignacion);

                    // Parámetros de salida
                    var pidAsignacion = new SqlParameter("@idAsignacion", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };


                    cmd.Parameters.Add(pidAsignacion);
                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto de autenticación
                    resp.idColaborador = obj.idColaborador;
                    resp.idTarea = obj.idTarea;
                    resp.fechaAsignacion = obj.fechaAsignacion;
                    resp.idAsignacion = Convert.ToInt32(pidAsignacion.Value.ToString());
                    resp.mensaje = pMensaje.Value.ToString();
                }

                return resp;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_Asignacion_Create "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassAsignacion_List_Resp> Connec_Asignacion_List(ClassAsignacion_List obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassAsignacion_List_Resp> List = new List<ClassAsignacion_List_Resp>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Asignacion_List";
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    cmd.Parameters.AddWithValue("@idTarea", obj.idTarea);
                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return List;

                        // Cachear índices de columnas
                        int idxIdAsignacion = reader.GetOrdinal("IDASIGNACION");
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxIdTarea = reader.GetOrdinal("IDTAREA");
                        int idxFechaAsignacion = reader.GetOrdinal("FECHAASIGNACION");
                        int idxFechaCreacion = reader.GetOrdinal("FECHA_CREACION");
                        int idxFechaActualizacion = reader.GetOrdinal("FECHA_ACTUALIZACION");

                        while (reader.Read())
                        {
                            try
                            {
                                var objList = new ClassAsignacion_List_Resp
                                {
                                    idAsignacion = !reader.IsDBNull(idxIdAsignacion) ? reader.GetInt32(idxIdAsignacion) : 0,
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,
                                    idTarea = !reader.IsDBNull(idxIdTarea) ? reader.GetInt32(idxIdTarea) : 0,
                                    fechaAsignacion = !reader.IsDBNull(idxFechaAsignacion)
                                                       ? reader.GetDateTime(idxFechaAsignacion)
                                                       : (DateTime?)null,
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
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Asignacion_List: "
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
                logsFile.WriteLogs("\nError en Connec_Asignacion_List "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public ClassTarea_Create Connec_Tarea_Create(ClassTarea_Create obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                ClassTarea_Create resp = new ClassTarea_Create();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Tarea_Create";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@nombre", obj.nombre);
                    cmd.Parameters.AddWithValue("@descripcion", obj.descripcion);

                    // Parámetros de salida
                    var pidTarea = new SqlParameter("@idTarea", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };


                    cmd.Parameters.Add(pidTarea);
                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto
                    resp.nombre = obj.nombre;
                    resp.descripcion = obj.descripcion;
                    resp.idTarea = Convert.ToInt32(pidTarea.Value.ToString());
                    resp.mensaje = pMensaje.Value.ToString();
                }

                return resp;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_Tarea_Create "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_Tarea_Update(ClassTarea_Update obj)
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
                ClassTarea_Update resp = new ClassTarea_Update();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Tarea_Update";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idTarea", obj.idTarea);
                    cmd.Parameters.AddWithValue("@nombre", obj.nombre);
                    cmd.Parameters.AddWithValue("@descripcion", obj.descripcion);

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
                logsFile.WriteLogs("\n" + "Error en Connec_Tarea_Update "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassTareaList> Connec_Tarea_List(ClassTareaListParam obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassTareaList> list = new List<ClassTareaList>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Tarea_List";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ⚡ Asignación correcta de parámetros
                    cmd.Parameters.AddWithValue("@FILTRO", (object?)obj.Filtro ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FECHA_INICIO", (object?)obj.fechaIniTarea ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FECHA_FIN", (object?)obj.fechafinTarea ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ID_COLABORADOR", obj.IdColaborador);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows)
                            return list;

                        // Cachear índices de columnas
                        int idxIdTarea = reader.GetOrdinal("IDTAREA");
                        int idxNombre = reader.GetOrdinal("NOMBRE");
                        int idxDescripcion = reader.GetOrdinal("DESCRIPCION");
                        int idxEstadoTarea = reader.GetOrdinal("ESTADOTAREA");
                        int idxFechaInicio = reader.GetOrdinal("FECHA_INICIO_TAREA");
                        int idxFechaFin = reader.GetOrdinal("FECHA_FIN_TAREA");
                        int idxIdAsignacion = reader.GetOrdinal("IDASIGNACION");
                        int idxFechaAsignacion = reader.GetOrdinal("FECHAASIGNACION");
                        int idxEstadoAsignacion = reader.GetOrdinal("ESTADO_ASIGNACION_TAREA");
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxNombreColaborador = reader.GetOrdinal("NOMBRE_COLABORADOR");
                        int idxApellido = reader.GetOrdinal("APELLIDO");
                        int idxCorreo = reader.GetOrdinal("CORREO");
                        int idxTelefono = reader.GetOrdinal("TELEFONO");
                        int idxRol = reader.GetOrdinal("ROL");
                        int idxEstadoColaborador = reader.GetOrdinal("ESTADOCOLABORADOR");

                        while (reader.Read())
                        {
                            try
                            {
                                var objList = new ClassTareaList
                                {
                                    idTarea = !reader.IsDBNull(idxIdTarea) ? reader.GetInt32(idxIdTarea) : 0,
                                    Nombre = !reader.IsDBNull(idxNombre) ? reader.GetString(idxNombre) : "",
                                    Descripcion = !reader.IsDBNull(idxDescripcion) ? reader.GetString(idxDescripcion) : "",
                                    estadoTarea = !reader.IsDBNull(idxEstadoTarea) ? reader.GetString(idxEstadoTarea) : "",
                                    fechafinTarea = !reader.IsDBNull(idxFechaFin) ? reader.GetDateTime(idxFechaFin) : (DateTime?)null,

                                    // Asignación
                                    idAsignacion = !reader.IsDBNull(idxIdAsignacion) ? reader.GetInt32(idxIdAsignacion) : (int?)null,
                                    fechaAsignacion = !reader.IsDBNull(idxFechaAsignacion) ? reader.GetDateTime(idxFechaAsignacion) : (DateTime?)null,
                                    estadoAsignacion = !reader.IsDBNull(idxEstadoAsignacion) ? reader.GetString(idxEstadoAsignacion) : "",

                                    // Colaborador
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : (int?)null,
                                    nombreColaborador = !reader.IsDBNull(idxNombreColaborador) ? reader.GetString(idxNombreColaborador) : "",
                                    apellido = !reader.IsDBNull(idxApellido) ? reader.GetString(idxApellido) : "",
                                    correo = !reader.IsDBNull(idxCorreo) ? reader.GetString(idxCorreo) : "",
                                    telefono = !reader.IsDBNull(idxTelefono) ? reader.GetString(idxTelefono) : "",
                                    rol = !reader.IsDBNull(idxRol) ? reader.GetString(idxRol) : "",
                                    estadoColaborador = !reader.IsDBNull(idxEstadoColaborador) ? reader.GetString(idxEstadoColaborador) : ""
                                };

                                list.Add(objList);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Tarea_List: "
                                                   + rowEx.Message + " "
                                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                                continue;
                            }
                        }
                    }
                }

                return list;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\nError en Connec_Tarea_List "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }
    }
}
