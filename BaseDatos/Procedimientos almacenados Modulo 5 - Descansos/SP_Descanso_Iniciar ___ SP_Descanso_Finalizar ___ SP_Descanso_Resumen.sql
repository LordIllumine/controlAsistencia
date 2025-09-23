----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Descanso_Iniciar / SP_Descanso_Finalizar / SP_Descanso_Resumen
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimientos para iniciar, finalizar y listar (filtrado por colaborador & date) los descansos
----------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE SP_Descanso_Iniciar
  @idAsignacion INT,
  @tipoDescanso NVARCHAR(50),
  @horaInicio   DATETIME,
  @idDescanso   INT OUT,
  @mensaje      NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    INSERT INTO DESCANSOS (IDASIGNACION, TIPODESCANSO, HORAINICIO, HORAFIN)
    VALUES (@idAsignacion, @tipoDescanso, @horaInicio, @horaInicio);

    SET @idDescanso = SCOPE_IDENTITY();
    SET @mensaje = N'Descanso iniciado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al iniciar descanso.';
    --EXEC SP_Bitacora_LogError N'Descanso_Iniciar', ERROR_MESSAGE;
	INSERT INTO BITACORA_ERRORES ( FECHA_CREACION, MODULO , ERROR) 
	VALUES (SYSDATETIME(), COALESCE(ERROR_PROCEDURE(), 'APLIX.ARTICULOS_EDITADOS_RECIENTEMENTE'), ERROR_MESSAGE())
  END CATCH
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Descanso_Iniciar
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1
----------------------------------------------------------------------------------------------------
-- DESCANSO_INICIAR - ÉXITO
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- Semillas: colaborador, tarea y asignación
  DECLARE @idCol INT, @idTarea INT, @idAsig INT, @idDesc INT, @msg NVARCHAR(200);
  DECLARE @pref NVARCHAR(100) = N'test.desc.iniciar.' + CONVERT(NVARCHAR(36), NEWID());
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Test',N'Desc',@pref+N'@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS(NOMBRE) VALUES(@pref+N' tarea'); SET @idTarea = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES(@idCol,@idTarea, GETDATE()); SET @idAsig = SCOPE_IDENTITY();

  DECLARE @inicio DATETIME = DATEADD(MINUTE, 0, CAST(GETDATE() AS DATETIME));

  EXEC dbo.SP_Descanso_Iniciar
       @idAsignacion=@idAsig, @tipoDescanso=N'COFFEE',
       @horaInicio=@inicio, @idDescanso=@idDesc OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Descanso_Iniciar (éxito)',
    Estado = CASE WHEN @msg LIKE N'Descanso iniciado%' AND @idDesc IS NOT NULL AND
                        EXISTS(SELECT 1 FROM dbo.DESCANSOS
                               WHERE IDDESCANSO=@idDesc AND IDASIGNACION=@idAsig
                                     AND TIPODESCANSO=N'COFFEE'
                                     AND HORAINICIO=@inicio AND HORAFIN=@inicio)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Fila creada con HORAINICIO=HORAFIN e ID devuelto';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Descanso_Iniciar (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/
CREATE OR ALTER PROCEDURE SP_Descanso_Finalizar
  @idDescanso INT,
  @horaFin    DATETIME,
  @mensaje    NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @inicio DATETIME;
    SELECT @inicio = HORAINICIO FROM DESCANSOS WHERE IDDESCANSO = @idDescanso;

    IF @inicio IS NULL
    BEGIN
      SET @mensaje = N'No se encontró el descanso.';
      RETURN;
    END
    IF @horaFin <= @inicio
    BEGIN
      SET @mensaje = N'La hora de fin debe ser mayor que la de inicio.';
      RETURN;
    END

    UPDATE DESCANSOS
       SET HORAFIN = @horaFin,
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDDESCANSO = @idDescanso;

    SET @mensaje = N'Descanso finalizado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al finalizar descanso.';
    EXEC SP_Bitacora_LogError N'Descanso_Finalizar', ERROR_MESSAGE;
  END CATCH
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Descanso_Finalizar
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1
----------------------------------------------------------------------------------------------------
-- DESCANSO_FINALIZAR - ÉXITO (fin > inicio)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- Semillas + iniciar descanso
  DECLARE @idCol INT, @idTarea INT, @idAsig INT, @idDesc INT, @msg NVARCHAR(200);
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Test',N'FinOK',N'finok@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREAS(NOMBRE) VALUES(N'tarea fin ok'); SET @idTarea = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES(@idCol,@idTarea,GETDATE()); SET @idAsig=SCOPE_IDENTITY();

  DECLARE @ini DATETIME = DATEADD(MINUTE, -30, GETDATE());
  DECLARE @fin DATETIME = DATEADD(MINUTE, -10, GETDATE()); -- 20 min

  EXEC dbo.SP_Descanso_Iniciar @idAsig, N'LUNCH', @ini, @idDesc OUTPUT, @msg OUTPUT;

  EXEC dbo.SP_Descanso_Finalizar @idDescanso=@idDesc, @horaFin=@fin, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Descanso_Finalizar (éxito)',
    Estado = CASE WHEN @msg LIKE N'Descanso finalizado%' AND
                        EXISTS(SELECT 1 FROM dbo.DESCANSOS
                               WHERE IDDESCANSO=@idDesc AND HORAFIN=@fin
                                     AND FECHA_ACTUALIZACION IS NOT NULL) AND
                        (SELECT DATEDIFF(MINUTE, HORAINICIO, HORAFIN) FROM dbo.DESCANSOS WHERE IDDESCANSO=@idDesc) = 20
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Minutos calculados = 20 y fecha de actualización seteada';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Descanso_Finalizar (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 2
----------------------------------------------------------------------------------------------------
-- DESCANSO_FINALIZAR - VALIDACIÓN (fin ≤ inicio)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idTarea INT, @idAsig INT, @idDesc INT, @msg NVARCHAR(200);
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Test',N'FinBad',N'finbad@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREAS(NOMBRE) VALUES(N'tarea fin bad'); SET @idTarea = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES(@idCol,@idTarea,GETDATE()); SET @idAsig=SCOPE_IDENTITY();

  DECLARE @ini DATETIME = DATEADD(MINUTE, -10, GETDATE());
  DECLARE @fin DATETIME = DATEADD(MINUTE, -20, GETDATE()); -- fin < inicio

  EXEC dbo.SP_Descanso_Iniciar @idAsig, N'BREAK', @ini, @idDesc OUTPUT, @msg OUTPUT;

  EXEC dbo.SP_Descanso_Finalizar @idDescanso=@idDesc, @horaFin=@fin, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Descanso_Finalizar (fin ≤ inicio)',
    Estado = CASE WHEN @msg LIKE N'La hora de fin debe ser mayor que la de inicio%' AND
                        EXISTS(SELECT 1 FROM dbo.DESCANSOS WHERE IDDESCANSO=@idDesc AND HORAFIN=@ini)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'HORAFIN se mantuvo = HORAINICIO (sin cambios)';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Descanso_Finalizar (fin ≤ inicio)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 3
----------------------------------------------------------------------------------------------------
-- DESCANSO_FINALIZAR - ID INEXISTENTE
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Descanso_Finalizar @idDescanso = -1, @horaFin = GETDATE, @mensaje = @msg OUTPUT;

  SELECT
    Caso   = N'Descanso_Finalizar (ID inexistente)',
    Estado = CASE WHEN @msg LIKE N'No se encontró el descanso%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin modificaciones en DESCANSOS';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Descanso_Finalizar (ID inexistente)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/
CREATE OR ALTER PROCEDURE SP_Descanso_Resumen
  @idColaborador INT = NULL,
  @desde DATETIME,
  @hasta DATETIME
AS
BEGIN
  SET NOCOUNT ON;
  SELECT ta.IDCOLABORADOR,
         SUM(DATEDIFF(MINUTE, d.HORAINICIO, d.HORAFIN)) AS MINUTOS_DESCANSO
  FROM DESCANSOS d
  JOIN TAREASASIGNADAS ta ON ta.IDASIGNACION = d.IDASIGNACION
  WHERE d.HORAINICIO BETWEEN @desde AND @hasta
    AND (@idColaborador IS NULL OR ta.IDCOLABORADOR = @idColaborador)
  GROUP BY ta.IDCOLABORADOR;
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Descanso_Resumen
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1
----------------------------------------------------------------------------------------------------
-- DESCANSO_RESUMEN - DOS COLABORADORES (30 y 5 min)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- Semillas: 2 colaboradores, 1 tarea, 2 asignaciones
  DECLARE @idColA INT, @idColB INT, @idTar INT, @idAsigA INT, @idAsigB INT;
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Ana',N'Desc',N'ana@ex.com',N'0',N'USER',1);
  SET @idColA = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Bruno',N'Desc',N'bruno@ex.com',N'0',N'USER',1);
  SET @idColB = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS(NOMBRE) VALUES(N'Tarea Desc'); SET @idTar = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES(@idColA,@idTar,GETDATE()); SET @idAsigA = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES(@idColB,@idTar,GETDATE()); SET @idAsigB = SCOPE_IDENTITY();

  -- Descansos: A (10 + 20 = 30), B (5)
  DECLARE @base DATETIME = DATEADD(HOUR, -3, GETDATE());
  INSERT INTO dbo.DESCANSOS(IDASIGNACION,TIPODESCANSO,HORAINICIO,HORAFIN)
  VALUES (@idAsigA,N'COFFEE', DATEADD(MINUTE,  0, @base), DATEADD(MINUTE, 10, @base)),
         (@idAsigA,N'BREAK',  DATEADD(MINUTE, 60, @base), DATEADD(MINUTE, 80, @base)),
         (@idAsigB,N'WATER',  DATEADD(MINUTE, 30, @base), DATEADD(MINUTE, 35, @base));

  DECLARE @desde DATETIME = DATEADD(HOUR, -4, GETDATE());
  DECLARE @hasta DATETIME = DATEADD(HOUR,  4, GETDATE());

  CREATE TABLE #r (IDCOLABORADOR INT, MINUTOS_DESCANSO INT);
  INSERT INTO #r EXEC dbo.SP_Descanso_Resumen @idColaborador=NULL, @desde=@desde, @hasta=@hasta;

  SELECT
    Caso   = N'Descanso_Resumen (todos)',
    Estado = CASE WHEN EXISTS(SELECT 1 FROM #r WHERE IDCOLABORADOR=@idColA AND MINUTOS_DESCANSO=30)
                    AND EXISTS(SELECT 1 FROM #r WHERE IDCOLABORADOR=@idColB AND MINUTOS_DESCANSO=5)
                  THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'n/a',
    Verificacion = CONCAT(N'A=',(SELECT MINUTOS_DESCANSO FROM #r WHERE IDCOLABORADOR=@idColA),
                          N' | B=',(SELECT MINUTOS_DESCANSO FROM #r WHERE IDCOLABORADOR=@idColB));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Descanso_Resumen (todos)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 2
----------------------------------------------------------------------------------------------------
-- DESCANSO_RESUMEN - FILTRO POR COLABORADOR (A = 30 min)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- Semillas rápidas
  DECLARE @idColA INT, @idTar INT, @idAsigA INT;
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Ana',N'Filtro',N'ana.filtro@ex.com',N'0',N'USER',1);
  SET @idColA = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREAS(NOMBRE) VALUES(N'Tarea Filtro'); SET @idTar = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES(@idColA,@idTar,GETDATE()); SET @idAsigA = SCOPE_IDENTITY();

  DECLARE @b DATETIME = DATEADD(HOUR, -2, GETDATE());
  INSERT INTO dbo.DESCANSOS(IDASIGNACION,TIPODESCANSO,HORAINICIO,HORAFIN)
  VALUES (@idAsigA,N'COFFEE', DATEADD(MINUTE, 0, @b), DATEADD(MINUTE,10, @b)),
         (@idAsigA,N'BREAK',  DATEADD(MINUTE,20, @b), DATEADD(MINUTE,40, @b));

  DECLARE @desde DATETIME = DATEADD(HOUR, -3, GETDATE());
  DECLARE @hasta DATETIME = DATEADD(HOUR,  3, GETDATE());

  CREATE TABLE #r (IDCOLABORADOR INT, MINUTOS_DESCANSO INT);
  INSERT INTO #r EXEC dbo.SP_Descanso_Resumen @idColaborador=@idColA, @desde=@desde, @hasta=@hasta;

  SELECT
    Caso   = N'Descanso_Resumen (filtro colaborador)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #r)=1
                       AND EXISTS(SELECT 1 FROM #r WHERE IDCOLABORADOR=@idColA AND MINUTOS_DESCANSO=30)
                  THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'n/a',
    Verificacion = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #r),' | Minutos=',(SELECT MINUTOS_DESCANSO FROM #r));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Descanso_Resumen (filtro colaborador)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/