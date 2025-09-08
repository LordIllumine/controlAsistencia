using ApiControlTiempo.Class;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ApiControlTiempo.Connection
{
    public class ConnectionAuthentificate
    {
        private DateTime thisDay;

        ClassLogsFile logsFile = new ClassLogsFile();
        private readonly string _schema;

        public ConnectionAuthentificate(IConfiguration configuration)
        {
            _schema = configuration["Schema:_schema"];
            // También podrías usar: configuration.GetSection("Schema")["_schema"]
        }

        public List<ClassAuthentificate> Connec_Authentication(ClassAuthentificate user)
        {
            thisDay = DateTime.Now;
            var ListCredenciales = new List<ClassAuthentificate>();

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
                    cmd.CommandText = "SP_Auth_Login";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@correo", user.Usuario);
                    cmd.Parameters.AddWithValue("@password", user.Contrasena);

                    // Parámetros de salida
                    var pCorreoUsuario = new SqlParameter("@correoResp", SqlDbType.NVarChar, 150)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pPass = new SqlParameter("@passwordResp", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pIdColaborador = new SqlParameter("@idColaborador", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pRol = new SqlParameter("@rol", SqlDbType.NVarChar, 50)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pCorreoUsuario);
                    cmd.Parameters.Add(pPass);
                    cmd.Parameters.Add(pIdColaborador);
                    cmd.Parameters.Add(pRol);
                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el objeto de autenticación
                    ClassAuthentificate val_cre = new ClassAuthentificate
                    {
                        Usuario = pCorreoUsuario.Value?.ToString(),
                        Contrasena = pPass.Value?.ToString(),
                        Rol = pRol.Value?.ToString(),
                        IdColaborador = pIdColaborador.Value != DBNull.Value ? Convert.ToInt32(pIdColaborador.Value) : 0,
                        Mensaje = pMensaje.Value?.ToString()
                    };

                    ListCredenciales.Add(val_cre);
                }

                return ListCredenciales;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error al obtener los credenciales "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_ResetPassword(ClassResetPassword ResetPass)
        {
            thisDay = DateTime.Now;
            string mensaje = string.Empty;

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
                    cmd.CommandText = "SP_Auth_ChangePassword";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@idColaborador", ResetPass.idColaborador);
                    cmd.Parameters.AddWithValue("@passwordActual", ResetPass.passwordActual);
                    cmd.Parameters.AddWithValue("@passwordNueva", ResetPass.passwordNueva);

                    // Parámetros de salida
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el retorno 
                    mensaje = pMensaje.Value?.ToString();
                }

                return mensaje;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_ResetPassword "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public ClassResetPasswordRequest Connec_ResetPasswordRequest(ClassResetPasswordRequest ResetPass)
        {
            thisDay = DateTime.Now;
            string mensaje = string.Empty;

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                Connection cnn = new Connection(configuration);
                ClassResetPasswordRequest objPass = new ClassResetPasswordRequest();

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = cnn.AbrirConexion();
                    cmd.CommandText = "SP_Auth_ResetPassword_Request";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@correo", ResetPass.correo);

                    // Parámetros de salida
                    var pToken = new SqlParameter("@token", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pToken);
                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el retorno 

                    objPass.correo = ResetPass.correo;
                    objPass.token = pToken.Value?.ToString();
                    objPass.Mensaje = pMensaje.Value?.ToString();
                }

                return objPass;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_ResetPasswordRequest "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }

        public string Connec_ResetPasswordConfirm(ClassResetPasswordComfirm ResetPass)
        {
            thisDay = DateTime.Now;
            string mensaje = string.Empty;

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
                    cmd.CommandText = "SP_Auth_ResetPassword_Confirm";
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parámetros de entrada
                    cmd.Parameters.AddWithValue("@correo", ResetPass.correo);
                    cmd.Parameters.AddWithValue("@passwordNueva", ResetPass.passwordNueva);

                    // Parámetros de salida
                    var pMensaje = new SqlParameter("@mensaje", SqlDbType.NVarChar, 200)
                    {
                        Direction = ParameterDirection.Output
                    };

                    cmd.Parameters.Add(pMensaje);

                    // Ejecutamos (no hay reader porque no devuelve un SELECT)
                    cmd.ExecuteNonQuery();

                    // Construimos el retorno 
                    mensaje = pMensaje.Value?.ToString();
                }

                return mensaje;
            }
            catch (Exception ex)
            {
                logsFile.WriteLogs("\n" + "Error en Connec_ResetPasswordConfirm "
                                   + ex.Message.ToString() + " "
                                   + thisDay.ToString("MM/dd/yy H:mm:ss"));
                throw;
            }
        }
    }
}

