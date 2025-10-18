----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Tarea_Create / SP_Tarea_Update / SP_Tarea_List
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimientos CRUD de Tareas
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Tarea_Create
  @nombre		NVARCHAR(200),
  @descripcion	NVARCHAR(MAX) = NULL,
  @fechaInicio	DATETIME,
  @fechaFin		DATETIME,
  @idTarea		INT OUT,
  @mensaje		NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    INSERT INTO TAREAS (NOMBRE, DESCRIPCION) VALUES (@nombre, @descripcion);
    SET @idTarea = SCOPE_IDENTITY();
    SET @mensaje = N'Tarea creada.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al crear tarea.';
    EXEC SP_Bitacora_LogError N'Tarea_Create', ERROR_MESSAGE;
  END CATCH
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Tarea_Create
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
--Prueba 1
----------------------------------------------------------------------------------------------------
-- CREATE - ÉXITO (con descripción)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @nombre NVARCHAR(200) = N'Test Create OK ' + CONVERT(NVARCHAR(36), NEWID());
  DECLARE @desc   NVARCHAR(MAX) = N'Descripción de prueba.';
  DECLARE @id INT, @msg NVARCHAR(200);

  EXEC dbo.SP_Tarea_Create @nombre=@nombre, @descripcion=@desc, @idTarea=@id OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Tarea_Create (éxito)',
    Estado = CASE WHEN @msg LIKE N'Tarea creada%' AND
                        @id IS NOT NULL AND
                        EXISTS(SELECT 1 FROM dbo.TAREAS WHERE IDTAREA=@id AND NOMBRE=@nombre AND DESCRIPCION=@desc)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje = @msg,
    Detalle = N'ID creado=' + COALESCE(CONVERT(NVARCHAR(20),@id),N'NULL');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Tarea_Create (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
--Prueba 2
----------------------------------------------------------------------------------------------------
-- CREATE - ÉXITO (descripcion NULL)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @nombre NVARCHAR(200) = N'Test Create NULL ' + CONVERT(NVARCHAR(36), NEWID());
  DECLARE @id INT, @msg NVARCHAR(200);

  EXEC dbo.SP_Tarea_Create @nombre=@nombre, @descripcion=NULL, @idTarea=@id OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Tarea_Create (descr. NULL)',
    Estado = CASE WHEN @msg LIKE N'Tarea creada%' AND
                        EXISTS(SELECT 1 FROM dbo.TAREAS WHERE IDTAREA=@id AND NOMBRE=@nombre AND DESCRIPCION IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje = @msg,
    Detalle = N'ID creado=' + COALESCE(CONVERT(NVARCHAR(20),@id),N'NULL');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Tarea_Create (descr. NULL)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;

*/
CREATE OR ALTER PROCEDURE SP_Tarea_Update
  @idTarea INT,
  @nombre  NVARCHAR(200) = NULL,
  @descripcion NVARCHAR(MAX) = NULL,
  @mensaje NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    UPDATE TAREAS
       SET NOMBRE = COALESCE(@nombre, NOMBRE),
           DESCRIPCION = COALESCE(@descripcion, DESCRIPCION),
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDTAREA = @idTarea;

    IF @@ROWCOUNT = 0 SET @mensaje = N'No se encontró la tarea.'; ELSE SET @mensaje = N'Tarea actualizada.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al actualizar tarea.';
    EXEC SP_Bitacora_LogError N'Tarea_Update', ERROR_MESSAGE;
  END CATCH
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Tarea_Update
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
--Prueba 1
----------------------------------------------------------------------------------------------------
-- UPDATE - ÉXITO (nombre + descripción)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- Semilla
  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @n0 NVARCHAR(200) = N'Seed Upd ' + CONVERT(NVARCHAR(8), NEWID());
  INSERT INTO dbo.TAREAS(NOMBRE, DESCRIPCION) VALUES(@n0, N'seed');
  SET @id = SCOPE_IDENTITY();

  -- Update
  DECLARE @n1 NVARCHAR(200) = N'Nombre Actualizado ' + CONVERT(NVARCHAR(8), NEWID());
  DECLARE @d1 NVARCHAR(MAX) = N'Descripción actualizada';
  EXEC dbo.SP_Tarea_Update @idTarea=@id, @nombre=@n1, @descripcion=@d1, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Tarea_Update (éxito)',
    Estado = CASE WHEN @msg LIKE N'Tarea actualizada%' AND
                        EXISTS(SELECT 1 FROM dbo.TAREAS WHERE IDTAREA=@id AND NOMBRE=@n1 AND DESCRIPCION=@d1 AND FECHA_ACTUALIZACION IS NOT NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje = @msg,
    Detalle = N'Verificado NOMBRE/DESCRIPCION/FECHA_ACTUALIZACION';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Tarea_Update (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
--Prueba 2
----------------------------------------------------------------------------------------------------
-- UPDATE - COALESCE (no sobreescribe con NULL)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  INSERT INTO dbo.TAREAS(NOMBRE, DESCRIPCION) VALUES(N'Nombre Fijo', N'Desc inicial');
  SET @id = SCOPE_IDENTITY();

  EXEC dbo.SP_Tarea_Update @idTarea=@id, @nombre=NULL, @descripcion=N'Nueva desc', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Tarea_Update (NULL no sobreescribe)',
    Estado = CASE WHEN @msg LIKE N'Tarea actualizada%' AND
                        EXISTS(SELECT 1 FROM dbo.TAREAS WHERE IDTAREA=@id AND NOMBRE=N'Nombre Fijo' AND DESCRIPCION=N'Nueva desc')
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje = @msg,
    Detalle = N'NOMBRE se mantuvo; cambió DESCRIPCION';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Tarea_Update (NULL no sobreescribe)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
--Prueba 3
----------------------------------------------------------------------------------------------------
-- UPDATE - ID inexistente
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Tarea_Update @idTarea=-1, @nombre=N'X', @descripcion=N'Y', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Tarea_Update (ID inexistente)',
    Estado = CASE WHEN @msg LIKE N'No se encontró la tarea%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje = @msg,
    Detalle = N'Sin cambios en TAREAS';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Tarea_Update (ID inexistente)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
*/
CREATE OR ALTER PROCEDURE SP_Tarea_List
  @texto NVARCHAR(200) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT * FROM TAREAS
  WHERE (@texto IS NULL OR NOMBRE LIKE '%'+@texto+'%' OR DESCRIPCION LIKE '%'+@texto+'%');
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas para SP_Tarea_List
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
--Prueba 1
----------------------------------------------------------------------------------------------------
-- LIST - Filtro por texto
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @pref NVARCHAR(80) = N'test tareas ' + CONVERT(NVARCHAR(36), NEWID());
  -- 3 que deben coincidir + 1 que NO
  INSERT INTO dbo.TAREAS(NOMBRE, DESCRIPCION) VALUES
    (@pref + N' A', N'desc A'),
    (@pref + N' B', N'desc B'),
    (@pref + N' C', N'desc C'),
    (N'OTRA TAREA',  N'no match');

  -- Captura del result set del SP en #t
  SELECT TOP 0 * INTO #t FROM dbo.TAREAS;
  INSERT INTO #t EXEC dbo.SP_Tarea_List @texto=@pref;

  SELECT
    Caso   = N'Tarea_List (texto)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=3 AND NOT EXISTS(SELECT 1 FROM #t WHERE NOMBRE=N'OTRA TAREA')
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje = N'n/a',
    Detalle = CONCAT(N'Filas=', (SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Tarea_List (texto)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Detalle;
END CATCH;
*/