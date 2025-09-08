----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Colaborador_Create
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento que permite crear un nuevo colaborador
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Colaborador_Create
  @nombre   NVARCHAR(100),
  @apellido NVARCHAR(100),
  @correo   NVARCHAR(150),
  @telefono NVARCHAR(20),
  @rol      NVARCHAR(50),
  @estado   BIT,
  @password NVARCHAR(200),
  @idColaborador INT OUT,
  @mensaje  NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRAN;

    -- Política
    IF LEN(@password) < 8
       OR @password NOT LIKE '%[A-Z]%'
       OR @password NOT LIKE '%[a-z]%'
       OR @password NOT LIKE '%[0-9]%'
       OR @password NOT LIKE '%[^A-Za-z0-9 ]%'
       OR CHARINDEX(' ', @password) > 0
    BEGIN
      SET @mensaje = N'La contraseña inicial no cumple la política.';
      ROLLBACK TRAN;
      RETURN;
    END

    INSERT INTO COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
    VALUES (@nombre, @apellido, @correo, @telefono, @rol, @estado);

    SET @idColaborador = SCOPE_IDENTITY();

    INSERT INTO USUARIO (IDCOLABORADOR, CONTRASEÑA)
    VALUES (@idColaborador, @password);

    COMMIT TRAN;
    SET @mensaje = N'Colaborador creado correctamente.';
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    SET @mensaje = N'Error al crear colaborador.';
    EXEC SP_Bitacora_LogError N'Colaborador_Create', ERROR_MESSAGE;
  END CATCH
END
GO
------------------------------------------------------------------------------------------------------
-- Sección de pruebas
------------------------------------------------------------------------------------------------------
/*
-- PRUEBA 1: Éxito
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @nombre NVARCHAR(100) = N'Test';
  DECLARE @apellido NVARCHAR(100) = N'Exito';
  DECLARE @correo NVARCHAR(150) = N'test.colab.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @telefono NVARCHAR(20) = N'00000000';
  DECLARE @rol NVARCHAR(50) = N'USER';
  DECLARE @estado BIT = 1;
  DECLARE @password NVARCHAR(200) = N'Aa1!Inicio';  -- cumple política
  DECLARE @idOut INT, @msg NVARCHAR(200);

  EXEC dbo.SP_Colaborador_Create
       @nombre, @apellido, @correo, @telefono, @rol, @estado, @password,
       @idColaborador = @idOut OUTPUT, @mensaje = @msg OUTPUT;

  SELECT
    Caso   = N'Colaborador_Create (éxito)',
    Estado = CASE WHEN
                  @msg LIKE N'Colaborador creado correctamente%' AND
                  @idOut IS NOT NULL AND
                  EXISTS (SELECT 1 FROM dbo.COLABORADORES c
                          WHERE c.IDCOLABORADOR=@idOut AND c.CORREO=@correo AND c.ROL=@rol AND c.ESTADO=@estado) AND
                  EXISTS (SELECT 1 FROM dbo.[USUARIO] u
                          WHERE u.IDCOLABORADOR=@idOut AND u.[CONTRASEÑA]=@password)
                THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'COLABORADORES + USUARIO insertados con ID=' + COALESCE(CONVERT(NVARCHAR(20),@idOut),N'NULL');

  ROLLBACK;  -- sin basura
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Colaborador_Create (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

-- PRUEBA 2: Falla por política (contraseña inválida)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correo NVARCHAR(150) = N'test.colab.politica.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @msg NVARCHAR(200), @idOut INT;

  EXEC dbo.SP_Colaborador_Create
       @nombre=N'Test', @apellido=N'Politica', @correo=@correo, @telefono=N'00000000',
       @rol=N'USER', @estado=1, @password=N'abc12345',  -- >=8 pero sin MAYÚSCULA ni especial
       @idColaborador=@idOut OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Colaborador_Create (política inválida)',
    Estado = CASE WHEN @msg LIKE N'La contraseña inicial no cumple la política%' AND
                        NOT EXISTS (SELECT 1 FROM dbo.COLABORADORES WHERE CORREO=@correo)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'No se insertó COLABORADORES/USUARIO';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Colaborador_Create (política inválida)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

-- PRUEBA 3: Falla por espacios en contraseña
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correo NVARCHAR(150) = N'test.colab.space.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @msg NVARCHAR(200), @idOut INT;

  EXEC dbo.SP_Colaborador_Create
       @nombre=N'Test', @apellido=N'Espacio', @correo=@correo, @telefono=N'00000000',
       @rol=N'USER', @estado=1, @password=N'Aa1! Pass',  -- contiene espacio → debe fallar
       @idColaborador=@idOut OUTPUT, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Colaborador_Create (espacio en password)',
    Estado = CASE WHEN @msg LIKE N'La contraseña inicial no cumple la política%' AND
                        NOT EXISTS (SELECT 1 FROM dbo.COLABORADORES WHERE CORREO=@correo)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Bloqueado por CHARINDEX('' '', @password) > 0';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Colaborador_Create (espacio en password)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

*/