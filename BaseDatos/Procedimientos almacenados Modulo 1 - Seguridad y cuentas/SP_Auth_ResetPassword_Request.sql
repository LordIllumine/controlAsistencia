-------------------------------------------------
-- Procedimiento almacenado SP_Auth_ResetPassword_Request
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento que genera el token que se debe enviar al correo de recuperación
-------------------------------------------------

CREATE OR ALTER PROCEDURE SP_Auth_ResetPassword_Request
  @correo   NVARCHAR(150),
  @token    NVARCHAR(100) OUT,
  @mensaje  NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @id INT;
    SELECT @id = c.IDCOLABORADOR
      FROM COLABORADORES c
      WHERE c.CORREO = @correo AND c.ESTADO = 1;

    IF @id IS NULL
    BEGIN
      SET @mensaje = N'Correo no registrado o usuario inactivo.';
      RETURN;
    END

    -- Token efímero
    SET @token = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', CONCAT(@correo, GETDATE(), @id)), 1);
    SET @mensaje = N'Token de recuperación generado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al solicitar recuperación.';
    EXEC SP_Bitacora_LogError N'Auth_ResetPassword_Request', ERROR_MESSAGE;
  END CATCH
END
GO
-------------------------------------------------
-- Sección de Pruebas
-------------------------------------------------
/*
/*Seccion de pruebas 1*/
-- PRUEBA 1: Usuario ACTIVO (éxito)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correoOK NVARCHAR(150) = N'test.reset.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Activo', @correoOK, N'00000000', N'USER', 1);

  DECLARE @token NVARCHAR(100), @mensaje NVARCHAR(200);
  EXEC dbo.SP_Auth_ResetPassword_Request
       @correo=@correoOK, @token=@token OUTPUT, @mensaje=@mensaje OUTPUT;

  SELECT
    Caso          = N'Reset - usuario activo',
    Estado        = CASE WHEN @token IS NOT NULL AND @token LIKE N'0x%' AND @mensaje LIKE N'%recuperación generado%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje       = @mensaje,
    Token_preview = LEFT(COALESCE(@token, N''), 24);

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Reset - usuario activo' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, CAST(NULL AS NVARCHAR(24)) AS Token_preview;
END CATCH;

/*Seccion de pruebas 2*/
-- PRUEBA 2: Usuario INACTIVO (debe fallar)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correoIna NVARCHAR(150) = N'test.reset.inactivo.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Inactivo', @correoIna, N'00000000', N'USER', 0);

  DECLARE @token NVARCHAR(100), @mensaje NVARCHAR(200);
  EXEC dbo.SP_Auth_ResetPassword_Request
       @correo=@correoIna, @token=@token OUTPUT, @mensaje=@mensaje OUTPUT;

  SELECT
    Caso          = N'Reset - usuario inactivo',
    Estado        = CASE WHEN @token IS NULL AND @mensaje LIKE N'%no registrado o usuario inactivo%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje       = @mensaje,
    Token_preview = CAST(NULL AS NVARCHAR(24));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Reset - usuario inactivo' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, CAST(NULL AS NVARCHAR(24)) AS Token_preview;
END CATCH;

/*Seccion de pruebas 3*/
-- PRUEBA 3: Correo NO REGISTRADO (debe fallar)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  -- No insertamos nada a propósito

  DECLARE @correoNo NVARCHAR(150) = N'no.existe.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @token NVARCHAR(100), @mensaje NVARCHAR(200);

  EXEC dbo.SP_Auth_ResetPassword_Request
       @correo=@correoNo, @token=@token OUTPUT, @mensaje=@mensaje OUTPUT;

  SELECT
    Caso          = N'Reset - correo no registrado',
    Estado        = CASE WHEN @token IS NULL AND @mensaje LIKE N'%no registrado o usuario inactivo%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje       = @mensaje,
    Token_preview = CAST(NULL AS NVARCHAR(24));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Reset - correo no registrado' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, CAST(NULL AS NVARCHAR(24)) AS Token_preview;
END CATCH;
*/