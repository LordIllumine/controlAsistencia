using ApiControlTiempo.Class;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Collections.Generic;
using System.Data;
using static ApiControlTiempo.Class.ClassGestionColaboradores;

namespace ApiControlTiempo.Connection
{
    public class ConnetionGestionColaboradores
    {
        private DateTime thisDay;

        ClassLogsFile logsFile = new ClassLogsFile();
        private readonly string _schema;

        public ConnetionGestionColaboradores(IConfiguration configuration)
        {
            _schema = configuration["Schema:_schema"];
            // También podrías usar: configuration.GetSection("Schema")["_schema"]
        }

        public ClassCrearColaboradorResp Connec_CrearColaborador(ClassCrearColaborador user)
        {
            thisDay = DateTime.Now;

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
                    cmd.CommandText = "SP_Colaborador_Create";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@nombre", user.nombre);
                    cmd.Parameters.AddWithValue("@apellido", user.apellido);
                    cmd.Parameters.AddWithValue("@correo", user.correo);
                    cmd.Parameters.AddWithValue("@telefono", user.telefono);
                    cmd.Parameters.AddWithValue("@rol", user.rol);
                    cmd.Parameters.AddWithValue("@estado", user.estado);
                    cmd.Parameters.AddWithValue("@password", user.password);

                    // Parámetros de salida
                    var pIdColaborador = new SqlParameter("@idColaborador", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pIdColaborador);
                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto de autenticación
                    resp.idColaborador = Convert.ToInt32(pIdColaborador.Value.ToString());
                    resp.Mensaje = pMensaje.Value.ToString();
                }

                return resp;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_Authentication "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public ClassActColaboradorResp Connec_ActColaborador(ClassActColaborador user)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                ClassActColaboradorResp resp = new ClassActColaboradorResp();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Colaborador_Update";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", user.idColaborador);
                    cmd.Parameters.AddWithValue("@nombre", user.nombre);
                    cmd.Parameters.AddWithValue("@apellido", user.apellido);
                    cmd.Parameters.AddWithValue("@correo", user.correo);
                    cmd.Parameters.AddWithValue("@telefono", user.telefono);
                    cmd.Parameters.AddWithValue("@rol", user.rol);
                    cmd.Parameters.AddWithValue("@estado", user.estado);

                    // Parámetros de salida
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto de autenticación
                    resp.Mensaje = pMensaje.Value.ToString();
                }

                return resp;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_ActColaborador "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassConsultarColaborador> Connec_ConsultarColaboradorID(int idColaborador)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                ClassConsultarColaborador colaborador = null;
                List<ClassConsultarColaborador> ListColaborador = new List<ClassConsultarColaborador>();
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Colaborador_GetById"; 
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetro de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", idColaborador);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            colaborador = new ClassConsultarColaborador
                            {
                                idColaborador = reader["IDCOLABORADOR"] != DBNull.Value ? Convert.ToInt32(reader["IDCOLABORADOR"]) : 0,
                                nombre = reader["NOMBRE"]?.ToString(),
                                apellido = reader["APELLIDO"]?.ToString(),
                                correo = reader["CORREO"]?.ToString(),
                                telefono = reader["TELEFONO"]?.ToString(),
                                rol = reader["ROL"]?.ToString(),
                                estado = reader["ESTADO"] != DBNull.Value && Convert.ToBoolean(reader["ESTADO"])
                            };
                            
                            ListColaborador.Add(colaborador);
                        }
                    }
                }

                return ListColaborador;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_ConsultarColaboradorID "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public List<ClassConsultarColaborador> Connec_ConsultarColaboradorFiltro(ClassConsultarColaboradorFiltro ObjFiltro)
        {
            thisDay = DateTime.Now;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                List<ClassConsultarColaborador> listaColaboradores = new List<ClassConsultarColaborador>();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Colaborador_List"; // Asegúrate que el SP devuelve un SELECT
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetro de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", ObjFiltro.idColaborador);
                    cmd.Parameters.AddWithValue("@texto", ObjFiltro.texto);
                    cmd.Parameters.AddWithValue("@rol", ObjFiltro.rol);
                    cmd.Parameters.AddWithValue("@estado", ObjFiltro.estado);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var colaborador = new ClassConsultarColaborador
                            {
                                idColaborador = reader["IDCOLABORADOR"] != DBNull.Value ? Convert.ToInt32(reader["IDCOLABORADOR"]) : 0,
                                nombre = reader["NOMBRE"]?.ToString(),
                                apellido = reader["APELLIDO"]?.ToString(),
                                correo = reader["CORREO"]?.ToString(),
                                telefono = reader["TELEFONO"]?.ToString(),
                                rol = reader["ROL"]?.ToString(),
                                estado = reader["ESTADO"] != DBNull.Value && Convert.ToBoolean(reader["ESTADO"])
                            };

                            listaColaboradores.Add(colaborador);
                        }
                    }
                }

                return listaColaboradores;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_ConsultarColaboradorID "
                                   + ex.Message + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_ActColaboradorEstado(ClassActColaboradorEstado user)
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
                    cmd.CommandText = "SP_Colaborador_SetEstado";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", user.idColaborador);
                    cmd.Parameters.AddWithValue("@estado", user.estado);

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
                logsFile.WriteLogs("\n" + "Error en Connec_ActColaboradorEstado "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }
    }
}
