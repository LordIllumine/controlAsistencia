----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Asignacion_Create / SP_Asignacion_List
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimientos SP_Asignacion_Create asigna una tarea creada SP_Asignacion_List lista tareas asignadas
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Asignacion_Create
  @idColaborador INT,
  @idTarea       INT,
  @fechaAsignacion DATETIME,
  @idAsignacion  INT OUT,
  @mensaje       NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    INSERT INTO TAREASASIGNADAS (IDCOLABORADOR, IDTAREA, FECHAASIGNACION)
    VALUES (@idColaborador, @idTarea, @fechaAsignacion);

    SET @idAsignacion = SCOPE_IDENTITY();
    SET @mensaje = N'Asignación creada.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al crear la asignación.';
    EXEC SP_Bitacora_LogError N'Asignacion_Create', ERROR_MESSAGE;
  END CATCH
END
GO

CREATE OR ALTER PROCEDURE SP_Asignacion_List
  @idColaborador INT = NULL,
  @idTarea       INT = NULL,
  @desde DATETIME = NULL,
  @hasta DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT IDASIGNACION AS [IDENTIFICACION], IDCOLABORADOR AS [IDENTIFICADOR DE COLABORADOR], IDTAREA AS [IDENTIFICADOR DETAREA],
         FECHAASIGNACION AS [FECHA DE ASIGNACION], FECHA_CREACION AS [FECHA DE CREACION], FECHA_ACTUALIZACION AS [FECHA DE ACTUALIZACION]
  FROM TAREASASIGNADAS
  WHERE (@idColaborador IS NULL OR IDCOLABORADOR = @idColaborador)
    AND (@idTarea IS NULL OR IDTAREA = @idTarea)
    AND (@desde IS NULL OR FECHAASIGNACION >= @desde)
    AND (@hasta IS NULL OR FECHAASIGNACION <= @hasta);
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1 
----------------------------------------------------------------------------------------------------
-- ASIGNACION_CREATE - ÉXITO
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- Semillas: colaborador y tarea
  DECLARE @idCol INT, @idTarea INT, @idAsig INT, @msg NVARCHAR(200);
  DECLARE @pref NVARCHAR(100) = N'test.asig.create.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Test',N'Asign', @pref+N'@ex.com', N'0', N'USER', 1);
  SET @idCol = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS(NOMBRE,DESCRIPCION)
  VALUES (@pref+N' tarea', N'desc');
  SET @idTarea = SCOPE_IDENTITY();

  DECLARE @fecha DATETIME = DATEADD(HOUR, 9, CAST(GETDATE() AS DATETIME));

  EXEC dbo.SP_Asignacion_Create
       @idColaborador=@idCol, @idTarea=@idTarea, @fechaAsignacion=@fecha,
       @idAsignacion=@idAsig OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Asignacion_Create (éxito)',
    Estado = CASE WHEN @msg LIKE N'Asignación creada%' AND @idAsig IS NOT NULL AND
                        EXISTS(SELECT 1 FROM dbo.TAREASASIGNADAS
                               WHERE IDASIGNACION=@idAsig AND IDCOLABORADOR=@idCol AND IDTAREA=@idTarea
                                     AND FECHAASIGNACION=@fecha)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje = @msg,
    Detalle = N'ID asignación=' + COALESCE(CONVERT(NVARCHAR(20),@idAsig),N'NULL');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Asignacion_Create (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 2
----------------------------------------------------------------------------------------------------
-- ASIGNACION_LIST - FILTRO POR COLABORADOR
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idTarea1 INT, @idTarea2 INT;
  DECLARE @pref NVARCHAR(100) = N'test.asig.list.col.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Ana',N'Col', @pref+N'@ex.com', N'0', N'USER', 1);
  SET @idCol = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS(NOMBRE) VALUES (@pref+N' T1'); SET @idTarea1 = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREAS(NOMBRE) VALUES (@pref+N' T2'); SET @idTarea2 = SCOPE_IDENTITY();

  DECLARE @f DATETIME = DATEADD(HOUR, 10, CAST(GETDATE() AS DATETIME));
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES (@idCol,@idTarea1,@f), (@idCol,@idTarea2,@f);

  -- Capturamos el result set del SP
  SELECT TOP 0 * INTO #t FROM dbo.TAREASASIGNADAS;
  INSERT INTO #t EXEC dbo.SP_Asignacion_List @idColaborador=@idCol, @idTarea=NULL, @desde=NULL, @hasta=NULL;

  SELECT
    Caso   = N'Asignacion_List (por colaborador)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=2
                       AND NOT EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR<>@idCol)
                  THEN N'OK' ELSE N'FALLO' END,
    Mensaje = N'n/a',
    Detalle = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Asignacion_List (por colaborador)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 3
----------------------------------------------------------------------------------------------------
-- ASIGNACION_LIST - FILTRO POR TAREA
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol1 INT, @idCol2 INT, @idTarea INT;
  DECLARE @pref NVARCHAR(100) = N'test.asig.list.tarea.' + CONVERT(NVARCHAR(36), NEWID());
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'B1',N'Col',@pref+N'1@ex.com',N'0',N'USER',1);
  SET @idCol1 = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'B2',N'Col',@pref+N'2@ex.com',N'0',N'USER',1);
  SET @idCol2 = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS(NOMBRE) VALUES (@pref+N' Única'); SET @idTarea = SCOPE_IDENTITY();

  DECLARE @f DATETIME = DATEADD(HOUR, 11, CAST(GETDATE() AS DATETIME));
  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES (@idCol1,@idTarea,@f);

  SELECT TOP 0 * INTO #t FROM dbo.TAREASASIGNADAS;
  INSERT INTO #t EXEC dbo.SP_Asignacion_List @idColaborador=NULL, @idTarea=@idTarea, @desde=NULL, @hasta=NULL;

  SELECT
    Caso   = N'Asignacion_List (por tarea)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=1
                       AND NOT EXISTS(SELECT 1 FROM #t WHERE IDTAREA<>@idTarea)
                  THEN N'OK' ELSE N'FALLO' END,
    Mensaje = N'n/a',
    Detalle = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Asignacion_List (por tarea)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 4
----------------------------------------------------------------------------------------------------
-- ASIGNACION_LIST - RANGO DE FECHAS (incluye extremos)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idTarea INT;
  DECLARE @pref NVARCHAR(100) = N'test.asig.list.range.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'R',N'Range',@pref+N'@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS(NOMBRE) VALUES (@pref+N' T'); SET @idTarea = SCOPE_IDENTITY();

  DECLARE @d0 DATE = CAST(GETDATE() AS DATE);
  DECLARE @f1 DATETIME = DATEADD(HOUR, 9,  CAST(@d0 AS DATETIME));          -- desde
  DECLARE @f2 DATETIME = DATEADD(HOUR, 12, DATEADD(DAY,1, CAST(@d0 AS DATETIME))); -- medio
  DECLARE @f3 DATETIME = DATEADD(HOUR, 15, DATEADD(DAY,2, CAST(@d0 AS DATETIME))); -- hasta

  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES (@idCol,@idTarea,@f1), (@idCol,@idTarea,@f2), (@idCol,@idTarea,@f3);

  SELECT TOP 0 * INTO #t FROM dbo.TAREASASIGNADAS;
  INSERT INTO #t EXEC dbo.SP_Asignacion_List @idColaborador=@idCol, @idTarea=NULL, @desde=@f1, @hasta=@f3;

  SELECT
    Caso   = N'Asignacion_List (rango)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=3
                       AND MIN((SELECT FECHAASIGNACION FROM #t)) = @f1
                       AND MAX((SELECT FECHAASIGNACION FROM #t)) = @f3
                  THEN N'OK' ELSE N'FALLO' END,
    Mensaje = N'n/a',
    Detalle = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #t),' | incluye extremos');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Asignacion_List (rango)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 5
----------------------------------------------------------------------------------------------------
-- ASIGNACION_LIST - COMBINADO (colaborador + tarea + rango)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idTarea INT, @idTareaOtro INT;
  DECLARE @pref NVARCHAR(100) = N'test.asig.list.combo.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Combo',N'X',@pref+N'@ex.com',N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS(NOMBRE) VALUES (@pref+N' Principal'); SET @idTarea = SCOPE_IDENTITY();
  INSERT INTO dbo.TAREAS(NOMBRE) VALUES (@pref+N' Otra');      SET @idTareaOtro = SCOPE_IDENTITY();

  DECLARE @base DATE = CAST(GETDATE() AS DATE);
  DECLARE @a DATETIME = DATEADD(HOUR, 8,  CAST(@base AS DATETIME));           -- dentro
  DECLARE @b DATETIME = DATEADD(HOUR, 10, DATEADD(DAY,1, CAST(@base AS DATETIME))); -- dentro
  DECLARE @c DATETIME = DATEADD(HOUR, 12, DATEADD(DAY,2, CAST(@base AS DATETIME))); -- dentro
  DECLARE @fuera DATETIME = DATEADD(DAY, 5, @c);                                 -- fuera

  INSERT INTO dbo.TAREASASIGNADAS(IDCOLABORADOR,IDTAREA,FECHAASIGNACION)
  VALUES (@idCol,@idTarea,@a),
         (@idCol,@idTarea,@b),
         (@idCol,@idTarea,@c),
         (@idCol,@idTareaOtro,@b), -- misma fecha pero otra tarea (debe excluirse)
         (@idCol,@idTarea,@fuera); -- fuera de rango (debe excluirse)

  SELECT TOP 0 * INTO #t FROM dbo.TAREASASIGNADAS;
  INSERT INTO #t EXEC dbo.SP_Asignacion_List
       @idColaborador=@idCol, @idTarea=@idTarea, @desde=@a, @hasta=@c;

  SELECT
    Caso   = N'Asignacion_List (combinado)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=3
                       AND NOT EXISTS(SELECT 1 FROM #t WHERE IDTAREA<>@idTarea)
                       AND NOT EXISTS(SELECT 1 FROM #t WHERE FECHAASIGNACION<@a OR FECHAASIGNACION>@c)
                  THEN N'OK' ELSE N'FALLO' END,
    Mensaje = N'n/a',
    Detalle = CONCAT(N'Filas=',(SELECT COUNT(*) FROM #t),' | solo tarea principal y dentro del rango');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Asignacion_List (combinado)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
*/
