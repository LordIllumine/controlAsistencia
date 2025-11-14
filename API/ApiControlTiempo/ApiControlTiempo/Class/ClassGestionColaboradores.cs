using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ApiControlTiempo.Class
{
    public class ClassGestionColaboradores
    {
        public class ClassCrearColaborador
        {
            [Required]
            public string nombre { get; set; }
            [Required]
            public string apellido { get; set; }
            [Required]
            public string correo { get; set; }
            [Required]
            public string telefono { get; set; }
            [Required]
            public string rol { get; set; }
            [Required]
            public bool estado { get; set; }
            [Required]
            public string password { get; set; }
        }

        public class ClassCrearColaboradorResp
        {
            public int idColaborador { get; set; }
            public string? Mensaje { get; set; }
        }

        public class ClassActColaborador
        {
            [Required]
            public int idColaborador { get; set; }
            [Required]
            public string nombre { get; set; }
            [Required]
            public string apellido { get; set; }
            [Required]
            public string correo { get; set; }
            [Required]
            public string telefono { get; set; }
            [Required]
            public string rol { get; set; }
            [Required]
            public bool estado { get; set; }
            [Required]
            public string password { get; set; }
        }

        public class ClassActColaboradorResp
        {
            public string? Mensaje { get; set; }
        }

        public class ClassConsultarColaborador
        {
            public int idColaborador { get; set; }
            public string nombre { get; set; }
            public string apellido { get; set; }
            public string correo { get; set; }
            public string telefono { get; set; }
            public string rol { get; set; }
            public bool estado { get; set; }
        }

        public class ClassConsultarColaboradorUpdate
        {
            public int idColaborador { get; set; }
            public string nombre { get; set; }
            public string apellido { get; set; }
            public string correo { get; set; }
            public string telefono { get; set; }
            public string rol { get; set; }
            public bool estado { get; set; }
            public string password { get; set; }
        }

        public class ClassConsultarColaboradorFiltro
        {
            public int idColaborador { get; set; }
            public string? texto { get; set; } = null;
            public string? rol { get; set; } = null;
            public bool? estado { get; set; } = null;
        }

        public class ClassActColaboradorEstado
        {
            public int idColaborador { get; set; }
            public string rol { get; set; }
            public bool estado { get; set; }
        }
    }
}
