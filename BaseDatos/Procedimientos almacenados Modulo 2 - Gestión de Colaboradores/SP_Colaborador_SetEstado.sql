----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Colaborador_SetEstado
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento que permite cambiar el estado de un colaborador
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Colaborador_SetEstado
  @idColaborador INT,
  @estado BIT,
  @mensaje NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    UPDATE COLABORADORES
       SET ESTADO = @estado,
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDCOLABORADOR = @idColaborador;

    IF @@ROWCOUNT = 0
      SET @mensaje = N'No se encontró el colaborador.';
    ELSE
      SET @mensaje = N'Estado actualizado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al actualizar estado.';
    EXEC SP_Bitacora_LogError N'Colaborador_SetEstado', ERROR_MESSAGE;
  END CATCH
END
GO

----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
-- PRUEBA 1: SetEstado 1→0 (éxito)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.setestado.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'SetEstado', @correo, N'00000000', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  EXEC dbo.SP_Colaborador_SetEstado
       @idColaborador=@id, @estado=0, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'SetEstado (1→0, éxito)',
    Estado = CASE WHEN @msg LIKE N'Estado actualizado%' AND
                        EXISTS(SELECT 1 FROM dbo.COLABORADORES
                               WHERE IDCOLABORADOR=@id AND ESTADO=0 AND FECHA_ACTUALIZACION IS NOT NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'ESTADO=0 y FECHA_ACTUALIZACION seteada';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'SetEstado (1→0, éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

-- PRUEBA 2: ID inexistente (debe fallar)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Colaborador_SetEstado
       @idColaborador=-1, @estado=1, @mensaje=@msg OUTPUT;

  SELECT
    Caso         = N'SetEstado (ID inexistente)',
    Estado       = CASE WHEN @msg LIKE N'No se encontró el colaborador%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin cambios en COLABORADORES';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'SetEstado (ID inexistente)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

-- PRUEBA 3: Misma bandera (1→1) debe actualizar la fecha
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.setestado.same.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Juan', N'Same', @correo, N'11111111', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  EXEC dbo.SP_Colaborador_SetEstado
       @idColaborador=@id, @estado=1, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'SetEstado (1→1, actualización de fecha)',
    Estado = CASE WHEN @msg LIKE N'Estado actualizado%' AND
                        EXISTS(SELECT 1 FROM dbo.COLABORADORES
                               WHERE IDCOLABORADOR=@id AND ESTADO=1 AND FECHA_ACTUALIZACION IS NOT NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'ESTADO se mantiene en 1; FECHA_ACTUALIZACION se estableció';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'SetEstado (1→1, actualización de fecha)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

*/