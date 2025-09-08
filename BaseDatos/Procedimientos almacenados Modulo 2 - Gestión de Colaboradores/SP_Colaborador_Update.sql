----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Colaborador_Update
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento que permite actualizar un colaborador
----------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE SP_Colaborador_Update
  @idColaborador INT,
  @nombre   NVARCHAR(100) = NULL,
  @apellido NVARCHAR(100) = NULL,
  @correo   NVARCHAR(150) = NULL,
  @telefono NVARCHAR(20)  = NULL,
  @rol      NVARCHAR(50)  = NULL,
  @estado   BIT           = NULL,
  @mensaje  NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    UPDATE COLABORADORES
       SET NOMBRE = COALESCE(@nombre, NOMBRE),
           APELLIDO = COALESCE(@apellido, APELLIDO),
           CORREO = COALESCE(@correo, CORREO),
           TELEFONO = COALESCE(@telefono, TELEFONO),
           ROL = COALESCE(@rol, ROL),
           ESTADO = COALESCE(@estado, ESTADO),
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDCOLABORADOR = @idColaborador;

    IF @@ROWCOUNT = 0
      SET @mensaje = N'No se encontró el colaborador.';
    ELSE
      SET @mensaje = N'Colaborador actualizado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al actualizar colaborador.';
    EXEC SP_Bitacora_LogError N'Colaborador_Update', ERROR_MESSAGE;
  END CATCH
END
GO

----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
--
-- PRUEBA 1: Éxito básico
--
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.update.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Update', @correo, N'00000000', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  EXEC dbo.SP_Colaborador_Update
       @idColaborador=@id,
       @telefono=N'11111111', @rol=N'ADMIN', @estado=0,
       @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Colaborador_Update (éxito básico)',
    Estado = CASE WHEN @msg LIKE N'Colaborador actualizado%' AND
                        EXISTS (SELECT 1 FROM dbo.COLABORADORES
                                WHERE IDCOLABORADOR=@id AND TELEFONO=N'11111111' AND ROL=N'ADMIN' AND ESTADO=0)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Teléfono/rol/estado cambiados, FECHA_ACTUALIZACION seteada';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Colaborador_Update (éxito básico)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
--
-- PRUEBA 2: No sobreescribe con NULL
--
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.update.null.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Ana', N'Perez', @correo, N'12345678', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  -- Enviamos NULL en nombre/apellido/correo/rol/estado; solo cambiamos teléfono
  EXEC dbo.SP_Colaborador_Update
       @idColaborador=@id,
       @telefono=N'99999999',
       @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Colaborador_Update (NULL no sobrescribe)',
    Estado = CASE WHEN @msg LIKE N'Colaborador actualizado%' AND
                        EXISTS (SELECT 1 FROM dbo.COLABORADORES
                                WHERE IDCOLABORADOR=@id
                                  AND NOMBRE=N'Ana' AND APELLIDO=N'Perez'
                                  AND CORREO=@correo
                                  AND TELEFONO=N'99999999' AND ROL=N'USER' AND ESTADO=1
                                  AND FECHA_ACTUALIZACION IS NOT NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Nombre/Apellido/Correo/Rol/Estado intactos; Teléfono actualizado';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Colaborador_Update (NULL no sobrescribe)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
-- 
-- PRUEBA 3: Actualización de datos personales
--
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.update.datos.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @correoNuevo NVARCHAR(150) = N'nuevo.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Juan', N'Lopez', @correo, N'1111', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  EXEC dbo.SP_Colaborador_Update
       @idColaborador=@id,
       @nombre=N'Juan Carlos', @apellido=N'Lopez R.', @correo=@correoNuevo,
       @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Colaborador_Update (datos personales)',
    Estado = CASE WHEN @msg LIKE N'Colaborador actualizado%' AND
                        EXISTS (SELECT 1 FROM dbo.COLABORADORES
                                WHERE IDCOLABORADOR=@id
                                  AND NOMBRE=N'Juan Carlos' AND APELLIDO=N'Lopez R.' AND CORREO=@correoNuevo)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Nombre/Apellido/Correo actualizados correctamente';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Colaborador_Update (datos personales)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
--
-- PRUEBA 4: ID inexistente
--
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @msg NVARCHAR(200);

  EXEC dbo.SP_Colaborador_Update
       @idColaborador = -1,               -- ID que no existe
       @telefono = N'88888888',
       @mensaje  = @msg OUTPUT;

  SELECT
    Caso         = N'Colaborador_Update (ID inexistente)',
    Estado       = CASE WHEN @msg LIKE N'No se encontró el colaborador%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin cambios en COLABORADORES';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Colaborador_Update (ID inexistente)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/