ALTER TABLE TAREASASIGNADAS ADD ESTADO VARCHAR(100) --COMPLETADAS / PENDIENTES 
GO

ALTER TABLE TAREAS ADD ESTADO VARCHAR(100) --ACTIVA / INACTIVA 
GO

CREATE OR ALTER PROCEDURE SP_Asignacion_List
  @idColaborador INT = NULL,
  @idTarea       INT = NULL,
  @desde DATETIME = NULL,
  @hasta DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT IDASIGNACION, IDCOLABORADOR, IDTAREA, ESTADO,
         FECHAASIGNACION, FECHA_CREACION, FECHA_ACTUALIZACION
  FROM TAREASASIGNADAS
  WHERE (@idColaborador IS NULL OR IDCOLABORADOR = @idColaborador)
    AND (@idTarea IS NULL OR IDTAREA = @idTarea)
    AND (@desde IS NULL OR FECHAASIGNACION >= @desde)
    AND (@hasta IS NULL OR FECHAASIGNACION <= @hasta);
END
GO

CREATE OR ALTER PROCEDURE SP_Tarea_Create
  @nombre    NVARCHAR(200),
  @descripcion NVARCHAR(MAX) = NULL,
  @idTarea   INT OUT,
  @mensaje   NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    INSERT INTO TAREAS (NOMBRE, DESCRIPCION, ESTADO) VALUES (@nombre, @descripcion, 'ACTIVA');
    SET @idTarea = SCOPE_IDENTITY();
    SET @mensaje = N'Tarea creada.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al crear tarea.';
    EXEC SP_Bitacora_LogError N'Tarea_Create', ERROR_MESSAGE;
  END CATCH
END
GO

CREATE OR ALTER PROCEDURE SP_Tarea_Update
  @idTarea INT,
  @nombre  NVARCHAR(200) = NULL,
  @descripcion NVARCHAR(MAX) = NULL,
  @Estado ESTADO VARCHAR(100),
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