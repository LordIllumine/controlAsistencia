// 1. Define el namespace (ajusta esto al nombre de tu proyecto)
namespace webControlAsistencia.Filters
{
    using Microsoft.AspNetCore.Mvc.Filters;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Http;

    public class SessionAuthorizeAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            // ... (Tu lógica de validación de sesión va aquí) ...

            // 3. Lógica para obtener el valor de la sesión
            var idColaborador = context.HttpContext.Session.GetString("IdColaborador");

            if (string.IsNullOrEmpty(idColaborador))
            {
                // Redirecciona antes de que el Controller se ejecute
                context.Result = new RedirectToActionResult("Index", "Login", null);
            }

            base.OnActionExecuting(context);
        }
    }
}