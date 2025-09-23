----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Permiso_Solicitar / SP_Permiso_CambiarEstado / SP_Permiso_List
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimientos 
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Permiso_Solicitar
  @idColaborador INT,
  @fechaInicio   DATETIME,
  @fechaFin      DATETIME,
  @motivo        NVARCHAR(MAX) = NULL,
  @idPermiso     INT OUT,
  @mensaje       NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    IF @fechaFin < @fechaInicio
    BEGIN
      SET @mensaje = N'El fin del permiso no puede ser anterior al inicio.';
      RETURN;
    END

    INSERT INTO PERMISOS (IDCOLABORADOR, FECHASOLICITUD, FECHAINICIO, FECHAFIN, MOTIVO, ESTADO)
    VALUES (@idColaborador, GETDATE(), @fechaInicio, @fechaFin, @motivo, N'Pendiente');

    SET @idPermiso = SCOPE_IDENTITY();
    SET @mensaje = N'Permiso solicitado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al solicitar permiso.';
    EXEC SP_Bitacora_LogError N'Permiso_Solicitar', ERROR_MESSAGE;
  END CATCH
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Permiso_Solicitar
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1
----------------------------------------------------------------------------------------------------
-- PERMISO_SOLICITAR - ÉXITO
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- Colaborador de prueba
  DECLARE @idCol INT, @idPerm INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150)=N'test.perm.ok.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Test',N'Perm',@correo,N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @fi DATETIME = DATEADD(HOUR, 1,  GETDATE());
  DECLARE @ff DATETIME = DATEADD(HOUR, 3,  GETDATE());

  EXEC dbo.SP_Permiso_Solicitar
       @idColaborador=@idCol, @fechaInicio=@fi, @fechaFin=@ff, @motivo=N'Médico',
       @idPermiso=@idPerm OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Permiso_Solicitar (éxito)',
    Estado = CASE WHEN @msg LIKE N'Permiso solicitado%' AND @idPerm IS NOT NULL AND
                        EXISTS(SELECT 1 FROM dbo.PERMISOS
                               WHERE IDPERMISO=@idPerm AND IDCOLABORADOR=@idCol
                                 AND FECHAINICIO=@fi AND FECHAFIN=@ff AND ESTADO=N'Pendiente')
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Fila creada con ESTADO=Pendiente e ID devuelto';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Permiso_Solicitar (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 2
----------------------------------------------------------------------------------------------------
-- PERMISO_SOLICITAR - VALIDACIÓN: fin < inicio (rechaza)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idPerm INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150)=N'test.perm.bad.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Test',N'Bad',@correo,N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @fi DATETIME = DATEADD(HOUR, 3, GETDATE());
  DECLARE @ff DATETIME = DATEADD(HOUR, 1, GETDATE()); -- menor que inicio

  EXEC dbo.SP_Permiso_Solicitar
       @idColaborador=@idCol, @fechaInicio=@fi, @fechaFin=@ff, @motivo=N'X',
       @idPermiso=@idPerm OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Permiso_Solicitar (fin < inicio)',
    Estado = CASE WHEN @msg LIKE N'El fin del permiso no puede ser anterior al inicio%' AND
                        NOT EXISTS(SELECT 1 FROM dbo.PERMISOS
                                   WHERE IDCOLABORADOR=@idCol AND FECHAINICIO=@fi AND FECHAFIN=@ff)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'No se insertó ningún permiso';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Permiso_Solicitar (fin < inicio)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

*/
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Permiso_Solicitar_update
  @idPermiso  INT,
  @nuevoEstado NVARCHAR(50),
  @mensaje    NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    UPDATE PERMISOS
       SET ESTADO = @nuevoEstado,
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDPERMISO = @idPermiso;

    IF @@ROWCOUNT = 0 SET @mensaje = N'No se encontró el permiso.'; ELSE SET @mensaje = N'Estado de permiso actualizado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al cambiar estado del permiso.';
    EXEC SP_Bitacora_LogError N'Permiso_CambiarEstado', ERROR_MESSAGE;
  END CATCH
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Permiso_Solicitar
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1
----------------------------------------------------------------------------------------------------
-- CAMBIAR_ESTADO - ÉXITO (Aprobado)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idPerm INT, @msg NVARCHAR(200);
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Juan',N'Estado',N'estado@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @fi DATETIME = DATEADD(DAY, 1, GETDATE());
  DECLARE @ff DATETIME = DATEADD(DAY, 2, GETDATE());

  EXEC dbo.SP_Permiso_Solicitar @idCol, @fi, @ff, N'Viaje', @idPerm OUTPUT, @msg OUTPUT;

  EXEC dbo.SP_Permiso_CambiarEstado @idPermiso=@idPerm, @nuevoEstado=N'Aprobado', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Permiso_CambiarEstado (éxito)',
    Estado = CASE WHEN @msg LIKE N'Estado de permiso actualizado%' AND
                        EXISTS(SELECT 1 FROM dbo.PERMISOS
                               WHERE IDPERMISO=@idPerm AND ESTADO=N'Aprobado' AND FECHA_ACTUALIZACION IS NOT NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'ESTADO=Aprobado; FECHA_ACTUALIZACION seteada';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Permiso_CambiarEstado (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 2
----------------------------------------------------------------------------------------------------
-- CAMBIAR_ESTADO - ID INEXISTENTE
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Permiso_CambiarEstado @idPermiso=-1, @nuevoEstado=N'Aprobado', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Permiso_CambiarEstado (ID inexistente)',
    Estado = CASE WHEN @msg LIKE N'No se encontró el permiso%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin cambios en PERMISOS';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Permiso_CambiarEstado (ID inexistente)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Permiso_List
  @idColaborador INT = NULL,
  @estado        NVARCHAR(50) = NULL,
  @desde         DATETIME = NULL,
  @hasta         DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT *
  FROM PERMISOS
  WHERE (@idColaborador IS NULL OR IDCOLABORADOR = @idColaborador)
    AND (@estado IS NULL OR ESTADO = @estado)
    AND (@desde IS NULL OR FECHAINICIO >= @desde)
    AND (@hasta IS NULL OR FECHAFIN <= @hasta);
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Permiso_List
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1
----------------------------------------------------------------------------------------------------
-- LIST - FILTRO POR COLABORADOR
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol1 INT, @idCol2 INT, @idP INT, @msg NVARCHAR(200);
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Ana',N'List',N'ana.list@ex.com',N'0',N'USER',1);
  SET @idCol1 = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Luis',N'List',N'luis.list@ex.com',N'0',N'USER',1);
  SET @idCol2 = SCOPE_IDENTITY();

  DECLARE @fi DATETIME = DATEADD(HOUR, 2, GETDATE());
  DECLARE @ff DATETIME = DATEADD(HOUR, 5, GETDATE());

  EXEC dbo.SP_Permiso_Solicitar @idCol1, @fi, @ff, N'Caso 1', @idP OUTPUT, @msg OUTPUT;
  EXEC dbo.SP_Permiso_Solicitar @idCol1, DATEADD(DAY,1,@fi), DATEADD(DAY,1,@ff), N'Caso 2', @idP OUTPUT, @msg OUTPUT;
  EXEC dbo.SP_Permiso_Solicitar @idCol2, @fi, @ff, N'Caso otro', @idP OUTPUT, @msg OUTPUT;

  SELECT TOP 0 * INTO #t FROM dbo.PERMISOS;
  INSERT INTO #t EXEC dbo.SP_Permiso_List @idColaborador=@idCol1, @estado=NULL, @desde=NULL, @hasta=NULL;

  SELECT
    Caso   = N'Permiso_List (colaborador)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=2 AND NOT EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR<>@idCol1)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'n/a',
    Verificacion = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #t),' | Solo del colaborador 1');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Permiso_List (colaborador)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 2
----------------------------------------------------------------------------------------------------
-- LIST - FILTRO POR ESTADO
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idP1 INT, @idP2 INT, @msg NVARCHAR(200);
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Carla',N'Estado',N'carla.estado@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @fi DATETIME = DATEADD(DAY, 1, GETDATE());
  DECLARE @ff DATETIME = DATEADD(DAY, 2, GETDATE());

  EXEC dbo.SP_Permiso_Solicitar @idCol, @fi, @ff, N'Pendiente 1', @idP1 OUTPUT, @msg OUTPUT;
  EXEC dbo.SP_Permiso_Solicitar @idCol, DATEADD(DAY,3,@fi), DATEADD(DAY,3,@ff), N'Pendiente 2', @idP2 OUTPUT, @msg OUTPUT;
  EXEC dbo.SP_Permiso_CambiarEstado @idP1, N'Aprobado', @msg OUTPUT;

  SELECT TOP 0 * INTO #t FROM dbo.PERMISOS;
  INSERT INTO #t EXEC dbo.SP_Permiso_List @idColaborador=NULL, @estado=N'Aprobado', @desde=NULL, @hasta=NULL;

  SELECT
    Caso   = N'Permiso_List (estado=Aprobado)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=1 AND NOT EXISTS(SELECT 1 FROM #t WHERE ESTADO<>N'Aprobado')
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'n/a',
    Verificacion = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #t),' | Solo estado Aprobado');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Permiso_List (estado=Aprobado)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 3
----------------------------------------------------------------------------------------------------
-- LIST - RANGO DE FECHAS (incluye extremos)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idP INT, @msg NVARCHAR(200);
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Diego',N'Rango',N'diego.rango@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @d0 DATE = CAST(GETDATE() AS DATE);
  DECLARE @fi1 DATETIME = DATEADD(HOUR,  9, CAST(@d0 AS DATETIME));                -- = desde
  DECLARE @ff1 DATETIME = DATEADD(HOUR, 11, CAST(@d0 AS DATETIME));
  DECLARE @fi2 DATETIME = DATEADD(HOUR, 10, DATEADD(DAY,1,CAST(@d0 AS DATETIME)));
  DECLARE @ff2 DATETIME = DATEADD(HOUR, 12, DATEADD(DAY,1,CAST(@d0 AS DATETIME)));
  DECLARE @fi3 DATETIME = DATEADD(HOUR, 13, DATEADD(DAY,2,CAST(@d0 AS DATETIME)));
  DECLARE @ff3 DATETIME = DATEADD(HOUR, 15, DATEADD(DAY,2,CAST(@d0 AS DATETIME)));  -- = hasta

  EXEC dbo.SP_Permiso_Solicitar @idCol, @fi1, @ff1, N'R1', @idP OUTPUT, @msg OUTPUT;
  EXEC dbo.SP_Permiso_Solicitar @idCol, @fi2, @ff2, N'R2', @idP OUTPUT, @msg OUTPUT;
  EXEC dbo.SP_Permiso_Solicitar @idCol, @fi3, @ff3, N'R3', @idP OUTPUT, @msg OUTPUT;

  SELECT TOP 0 * INTO #t FROM dbo.PERMISOS;
  INSERT INTO #t EXEC dbo.SP_Permiso_List
       @idColaborador=@idCol, @estado=NULL, @desde=@fi1, @hasta=@ff3;

  SELECT
    Caso   = N'Permiso_List (rango fechas)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=3 THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'n/a',
    Verificacion = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #t),' | extremos incluidos');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Permiso_List (rango fechas)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

*/