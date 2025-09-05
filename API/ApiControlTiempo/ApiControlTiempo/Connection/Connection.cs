﻿using ApiControlTiempo.Class;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ApiControlTiempo.Connection
{
    public class Connection
    {
        private readonly string _cadenaConexion;
        ClassLogsFile Logs = new ClassLogsFile();
        public Connection(IConfiguration configuration)
        {
            _cadenaConexion = configuration.GetConnectionString("conexion");
        }

        public SqlConnection AbrirConexion()
        {
            SqlConnection v_Conexion = new SqlConnection(_cadenaConexion);

            try
            {
                if (v_Conexion.State == ConnectionState.Closed)
                    v_Conexion.Open();
            }
            catch (Exception ex)
            {
                Logs.WriteLogs($"Error al abrir conexión Error: {ex.Message}");
            }

            return v_Conexion;
        }

        public SqlConnection CerrarConexion(SqlConnection v_Conexion)
        {
            try
            {
                if (v_Conexion.State == ConnectionState.Open)
                    v_Conexion.Close();
            }
            catch (Exception ex)
            {
                Logs.WriteLogs($"Error al Cerrar conexión Error: {ex.Message}");
            }

            return v_Conexion;
        }
    }
}
