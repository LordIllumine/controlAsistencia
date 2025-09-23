using ApiControlTiempo.Class;
using Microsoft.Data.SqlClient;
using System.Data;
using static ApiControlTiempo.Class.ClassReportesyAnaliticaOperativa;

namespace ApiControlTiempo.Connection
{
    public class ConnectionReportesyAnaliticaOperativa
    {
        private DateTime thisDay;

        ClassLogsFile logsFile = new ClassLogsFile();
        private readonly string _schema;

        public ConnectionReportesyAnaliticaOperativa(IConfiguration configuration)
        {
            _schema = configuration["Schema:_schema"];
            // También podrías usar: configuration.GetSection("Schema")["_schema"]
        }

        public List<ClassReporte_AsistenciaDiaria> Connec_Reporte_AsistenciaDiaria(DateTime fecha)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassReporte_AsistenciaDiaria> Listcolaborador = new List<ClassReporte_AsistenciaDiaria>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Reporte_AsistenciaDiaria";
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@fecha", fecha);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return Listcolaborador;

                        // Cachear índices de columnas
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxNombre = reader.GetOrdinal("NOMBRE");
                        int idxApellido = reader.GetOrdinal("APELLIDO");
                        int idxfecha = reader.GetOrdinal("FECHA"); 
                        int idxHoraEntrada = reader.GetOrdinal("HORAENTRADA");
                        int idxHoraSalida = reader.GetOrdinal("HORASALIDA");

                        while (reader.Read())
                        {
                            try
                            {
                                var objColaborador = new ClassReporte_AsistenciaDiaria
                                {
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,
                                    nombre = !reader.IsDBNull(idxNombre) ? reader.GetString(idxNombre) : "",
                                    apellido = !reader.IsDBNull(idxApellido) ? reader.GetString(idxApellido) : "",
                                    fecha = !reader.IsDBNull(idxfecha)
                                                       ? reader.GetDateTime(idxfecha)
                                                       : (DateTime?)null,
                                    horaEntrada = !reader.IsDBNull(idxHoraEntrada)
                                                    ? reader.GetFieldValue<TimeSpan>(idxHoraEntrada)
                                                    : (TimeSpan?)null,
                                    horaSalida = !reader.IsDBNull(idxHoraSalida)
                                                    ? reader.GetFieldValue<TimeSpan>(idxHoraSalida)
                                                    : (TimeSpan?)null                               
                                };

                                Listcolaborador.Add(objColaborador);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Reporte_AsistenciaDiaria: "
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
                logsFile.WriteLogs("\nError en Connec_Reporte_AsistenciaDiaria "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassReporte_HorasTrabajadasResp> Connec_Reporte_HorasTrabajadas(ClassReporte_HorasTrabajadas obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassReporte_HorasTrabajadasResp> ListReporte = new List<ClassReporte_HorasTrabajadasResp>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Reporte_HorasTrabajadas";
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return ListReporte;

                        // Cachear índices de columnas
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxMinutosBrutos = reader.GetOrdinal("MINUTOS_BRUTOS");

                        while (reader.Read())
                        {
                            try
                            {
                                var objReporte = new ClassReporte_HorasTrabajadasResp
                                {
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,
                                    minutosBrutos = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0
                                };

                                ListReporte.Add(objReporte);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Reporte_HorasTrabajadas: "
                                                   + rowEx.Message + " "
                                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                                // Puedes decidir: continuar con las demás filas o lanzar excepción
                                continue;
                            }
                        }
                    }
                }

                return ListReporte;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\nError en Connec_Reporte_HorasTrabajadas "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassReporte_PermisosResp> Connec_Reporte_Permisos(ClassReporte_Permisos obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassReporte_PermisosResp> List = new List<ClassReporte_PermisosResp>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Reporte_Permisos";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);
                    cmd.Parameters.AddWithValue("@estado", obj.estado);

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
                                var objList = new ClassReporte_PermisosResp
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

        public List<ClassReporte_ProductividadResp> Connec_Reporte_Productividad(ClassReporte_Productividad obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassReporte_ProductividadResp> ListReporte = new List<ClassReporte_ProductividadResp>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Reporte_Productividad";
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return ListReporte;

                        // Cachear índices de columnas
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxMinutosTrabajao = reader.GetOrdinal("MINUTOS_TRABAJO");
                        int idxMinutosDescanso = reader.GetOrdinal("MINUTOS_DESCANSO");
                        int idxMinutosNetos = reader.GetOrdinal("MINUTOS_NETOS");

                        while (reader.Read())
                        {
                            try
                            {
                                var objReporte = new ClassReporte_ProductividadResp
                                {
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,
                                    minutosTrabajo = !reader.IsDBNull(idxMinutosTrabajao) ? reader.GetInt32(idxMinutosTrabajao) : 0,
                                    minutosDescanso = !reader.IsDBNull(idxMinutosDescanso) ? reader.GetInt32(idxMinutosDescanso) : 0,
                                    minutosNetos = !reader.IsDBNull(idxMinutosNetos) ? reader.GetInt32(idxMinutosNetos) : 0
                                };

                                ListReporte.Add(objReporte);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Reporte_Productividad: "
                                                   + rowEx.Message + " "
                                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                                // Puedes decidir: continuar con las demás filas o lanzar excepción
                                continue;
                            }
                        }
                    }
                }

                return ListReporte;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\nError en Connec_Reporte_Productividad "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }
    }
}
