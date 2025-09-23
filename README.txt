1. Editado SP = SP_Auth_Login.sql (CORRER)

2. El token hay que guardarlo en algun lado para validarlo en el otro SP que hace el cambio de contraseña (Guardar en base de datos) (IMPORTANTE)

3. SP_Colaborador_GetById hace el select con *

4. Faltan los triggers que actualizan los campos de fecha actualizacion en las tablas (TODAS LAS TABLAS QUE TIENEN EL CAMPO FECHA_ACTUALIZACION NO SE ACTUALIZA)

5. SP_Colaborador_List hace el select con *

6. SP_Colaborador_Create No regresa el ID del colaborador (IMPORTANTE)

7. SP_Asistencia_GetByRango hace el select con *

8. SP_Asistencia_MarcarEntrada porque no usar un datetime? en parametros Fecha y hora, (No lo cambie porque ya lo programe, es pregunta XD)

9. SP_Asistencia_MarcarSalida considerar mensaje de "ya hay un registro de salida para este dia" como pasa en SP marcar entrada

10. SP_Asignacion_List hace el select con *

11. SP_Bitacora_LogError no guarda el nombre del SP como tal sino algo similar puede deribar a dificultad para encontrar errores 
	con la funcion COALESCE(ERROR_PROCEDURE(), '') detecta el SP que fallo (recomendacion de codigo)

12. SP_Bitacora_LogError no guarda que fallo en el SP solo pone ERROR_MESSAGE o sea que no lo toma como funcion sino como texto (IMPORTANTE)

(Yo en los Try/CATCH pongo un insert como este: INSERT INTO VTEX.BITACORA_ERRORES_TABLAS_PROPIAS ( FECHA, PROCEDIMIENTO , ERROR) 
	VALUES (SYSDATETIME(), COALESCE(ERROR_PROCEDURE(), 'APLIX.ARTICULOS_EDITADOS_RECIENTEMENTE'), ERROR_MESSAGE()))

13. Los SP no tienen ni transaccion/commit ni rollback 

14. SP_Descanso_Iniciar no me da un error como tal solo me regresa "Error al iniciar descanso." pero cual es el error? ya existe? no existe? 
	
15. Agregar a todos los Sp con insert o update un IF EXISTS o IF NOT EXISTS para validar y poder regresar un error mas claro 

16. Editado SP_Permiso_Solicitar el insert y update se llaman igual cambie el update a SP_Permiso_Solicitar_update (CORRER)

17. SP_Permiso_List hace el select con *

18. Editado SP_Reporte_AsistenciaDiaria agregue la fecha (CORRER)
