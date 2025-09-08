using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassGestionColaboradores
    {
        public class ClassCrearColaborador
        {
            [JsonRequired]
            public string nombre { get; set; }
            [JsonRequired]
            public string apellido { get; set; }
            [JsonRequired]
            public string correo { get; set; }
            [JsonRequired]
            public string telefono { get; set; }
            [JsonRequired]
            public string rol { get; set; }
            [JsonRequired]
            public bool estado { get; set; }
            [JsonRequired]
            public string password { get; set; }
        }

        public class ClassCrearColaboradorResp
        {
            public int idColaborador { get; set; }
            public string? Mensaje { get; set; }
        }

        public class ClassActColaborador
        {
            [JsonRequired]
            public int idColaborador { get; set; }
            [JsonRequired]
            public string nombre { get; set; }
            [JsonRequired]
            public string apellido { get; set; }
            [JsonRequired]
            public string correo { get; set; }
            [JsonRequired]
            public string telefono { get; set; }
            [JsonRequired]
            public string rol { get; set; }
            [JsonRequired]
            public bool estado { get; set; }
            [JsonRequired]
            public string password { get; set; }
        }

        public class ClassActColaboradorResp
        {
            public string? Mensaje { get; set; }
        }

        public class ClassConsultarColaboradorId
        {
            public int idColaborador { get; set; }
            public string nombre { get; set; }
            public string apellido { get; set; }
            public string correo { get; set; }
            public string telefono { get; set; }
            public string rol { get; set; }
            public bool estado { get; set; }
        }
    }
}
