using Newtonsoft.Json;

namespace webControlAsistencia.Models
{
    public class ClassColaborador
    {

        [JsonProperty("idColaborador")]
        public int IdColaborador { get; set; }

        [JsonProperty("nombre")]
        public string Nombre { get; set; }

        [JsonProperty("apellido")]
        public string Apellido { get; set; }

        [JsonProperty("correo")]
        public string Correo { get; set; }

        [JsonProperty("telefono")]
        public string Telefono { get; set; }

        [JsonProperty("rol")]
        public string Rol { get; set; }

        [JsonProperty("estado")]
        public bool Estado { get; set; }
    }

    public class ClassColaboradorAList
    { 
        public List<ClassColaborador>? resp { get; set; }
        public string message { get; set; }
    }

    public class ClassColaboradorCrear
    {

        //[JsonProperty("idColaborador")]
        //public int IdColaborador { get; set; }

        [JsonProperty("nombre")]
        public string Nombre { get; set; }

        [JsonProperty("apellido")]
        public string Apellido { get; set; }

        [JsonProperty("correo")]
        public string Correo { get; set; }

        [JsonProperty("telefono")]
        public string Telefono { get; set; }

        [JsonProperty("rol")]
        public string Rol { get; set; }

        [JsonProperty("estado")]
        public bool Estado { get; set; } = true;

        [JsonProperty("password")]
        public string Contraseña { get; set; }
    }

    public class ClassColaboradorID
    {

        [JsonProperty("idColaborador")]
        public int IdColaborador { get; set; }

        [JsonProperty("nombre")]
        public string Nombre { get; set; }

        [JsonProperty("apellido")]
        public string Apellido { get; set; }

        [JsonProperty("correo")]
        public string Correo { get; set; }

        [JsonProperty("telefono")]
        public string Telefono { get; set; }

        [JsonProperty("rol")]
        public string Rol { get; set; }

        [JsonProperty("estado")]
        public bool Estado { get; set; } = true;

        [JsonProperty("password")]
        public string Contraseña { get; set; }
    }

    public class ClassColaboradorIDMain
    {
        public ClassColaboradorID objJson { get; set; }
    }

    public class ClassColaboradorRestCreate
    {
        public string message { get; set; }
    }
}
