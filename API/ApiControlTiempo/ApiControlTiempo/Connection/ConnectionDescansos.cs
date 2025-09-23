using ApiControlTiempo.Class;
using Microsoft.Data.SqlClient;
using System.Data;
using static ApiControlTiempo.Class.ClassDescansos;
using static ApiControlTiempo.Class.ClassGestionColaboradores;
using static ApiControlTiempo.Class.ClassTareasyAsignaciones;

namespace ApiControlTiempo.Connection
{
    public class ConnectionDescansos
    {

        private DateTime thisDay;

        ClassLogsFile logsFile = new ClassLogsFile();
        private readonly string _schema;

        public ConnectionDescansos(IConfiguration configuration)
        {
            _schema = configuration["Schema:_schema"];
            // También podrías usar: configuration.GetSection("Schema")["_schema"]
        }


        public string Connec_Descanso_Iniciar(ClassDescanso_Iniciar obj)
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
                ClassCrearColaboradorResp resp = new ClassCrearColaboradorResp();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Descanso_Iniciar";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idAsignacion", obj.idAsignacion);
                    cmd.Parameters.AddWithValue("@tipoDescanso", obj.tipoDescanso);
                    cmd.Parameters.AddWithValue("@horaInicio", obj.horaInicio);

                    // Parámetros de salida
                    var pIdDescanso = new SqlParameter("@idDescanso", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };


                    cmd.Parameters.Add(pIdDescanso);
                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto de autenticación
                    if (string.IsNullOrEmpty(pIdDescanso.Value.ToString()))
                    {
                        resp.idColaborador = 0;
                    }
                    else 
                    {
                        resp.idColaborador = Convert.ToInt32(pIdDescanso.Value.ToString());
                    }
                    
                    Mensaje = pMensaje.Value.ToString();
                }

                return Mensaje;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_Descanso_Iniciar "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_Descanso_Finalizar(ClassDescanso_Finalizar obj)
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
                ClassDescanso_Finalizar resp = new ClassDescanso_Finalizar();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Descanso_Finalizar";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idDescanso", obj.idDescanso);
                    cmd.Parameters.AddWithValue("@horaFin", obj.horaFin);

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
                logsFile.WriteLogs("\n" + "Error en Connec_Descanso_Finalizar "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassDescanso_ResumenResp> Connec_Descanso_Resumen(ClassDescanso_Resumen obj)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassDescanso_ResumenResp> List = new List<ClassDescanso_ResumenResp>();

                using (SqlConnection conn = cnn.AbrirConexion())
                using (SqlCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SP_Asignacion_List";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", obj.idColaborador);
                    cmd.Parameters.AddWithValue("@desde", obj.desde);
                    cmd.Parameters.AddWithValue("@hasta", obj.hasta);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.HasRows) return List;

                        // Cachear índices de columnas
                        int idxIdColaborador = reader.GetOrdinal("IDCOLABORADOR");
                        int idxMinutosDescanso = reader.GetOrdinal("IDASIGNACION");

                        while (reader.Read())
                        {
                            try
                            {
                                var objList = new ClassDescanso_ResumenResp
                                {
                                    idColaborador = !reader.IsDBNull(idxIdColaborador) ? reader.GetInt32(idxIdColaborador) : 0,
                                    minutosDescanso = !reader.IsDBNull(idxMinutosDescanso) ? reader.GetInt32(idxMinutosDescanso) : 0
                                };

                                List.Add(objList);
                            }
                            catch (Exception rowEx)
                            {
                                logsFile.WriteLogs("\nError al procesar fila en Connec_Descanso_Resumen: "
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
                logsFile.WriteLogs("\nError en Connec_Descanso_Resumen "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }
    }
}
