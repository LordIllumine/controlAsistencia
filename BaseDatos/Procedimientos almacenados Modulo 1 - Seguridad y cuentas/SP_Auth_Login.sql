----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Auth_Login
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento que permite la autenticación de usuarios en el login
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Auth_Login
  @correo        NVARCHAR(150),
  @password      NVARCHAR(200),
  @correoResp    NVARCHAR(150) OUT,
  @passwordResp  NVARCHAR(200) OUT,
  @idColaborador INT           OUT,
  @rol           NVARCHAR(50)  OUT,
  @mensaje       NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    SELECT TOP 1
	  @correoResp	 = c.CORREO,
	  @passwordResp  = u.CONTRASEÑA,
      @idColaborador = c.IDCOLABORADOR,
      @rol           = c.ROL
    FROM COLABORADORES c
    JOIN USUARIO u ON u.IDCOLABORADOR = c.IDCOLABORADOR
    WHERE c.CORREO = @correo
      AND u.CONTRASEÑA = @password
      AND c.ESTADO = 1;

    IF @idColaborador IS NULL
      SET @mensaje = N'Credenciales inválidas o usuario inactivo.';
    ELSE
      SET @mensaje = N'Autenticación exitosa.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al autenticar.';
    EXEC SP_Bitacora_LogError N'Auth_Login', ERROR_MESSAGE;
  END CATCH
END
GO

/*
-- Sección de pruebas

-- PRUEBA AUTO-CONTENIDA: crea datos de prueba y hace ROLLBACK al final
BEGIN TRY
  BEGIN TRAN;  -- no deja datos al final

  DECLARE @correoTmp NVARCHAR(150) = N'test.login.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @passTmp   NVARCHAR(200) = N'Aa1!prueba';  -- cumple política

  DECLARE @idTmp INT;

  -- Ajusta columnas si tu esquema requiere otras NOT NULL
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Login', @correoTmp, N'00000000', N'USER', 1);

  SET @idTmp = SCOPE_IDENTITY();

  INSERT INTO dbo.USUARIO (IDCOLABORADOR, CONTRASEÑA)
  VALUES (@idTmp, @passTmp);

  DECLARE @idOut INT, @rolOut NVARCHAR(50), @msgOut NVARCHAR(200);

  EXEC dbo.SP_Auth_Login
    @correo        = @correoTmp,
    @password      = @passTmp,
    @idColaborador = @idOut  OUTPUT,
    @rol           = @rolOut OUTPUT,
    @mensaje       = @msgOut OUTPUT;

  SELECT 'AUTO-CONTENIDA/ÉXITO' AS Caso,
         @correoTmp AS correoProbado,
         @idOut AS idColaborador, @rolOut AS rol, @msgOut AS mensaje;

  -- Prueba negativa con el mismo correo y password malo
  DECLARE @idBad INT, @rolBad NVARCHAR(50), @msgBad NVARCHAR(200);
  EXEC dbo.SP_Auth_Login
    @correo        = @correoTmp,
    @password      = N'BadPass123!',
    @idColaborador = @idBad  OUTPUT,
    @rol           = @rolBad OUTPUT,
    @mensaje       = @msgBad OUTPUT;

  SELECT 'AUTO-CONTENIDA/FALLA' AS Caso,
         @correoTmp AS correoProbado,
         @idBad AS idColaborador, @rolBad AS rol, @msgBad AS mensaje;

  ROLLBACK TRAN;  -- limpia los inserts de la prueba
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRAN;
  PRINT 'ERROR en la prueba: ' + ERROR_MESSAGE();
END CATCH;

*/


 SELECT TOP 1
	  c.CORREO,
	  u.CONTRASEÑA,
      c.IDCOLABORADOR,
      c.ROL
    FROM COLABORADORES c
    JOIN USUARIO u ON u.IDCOLABORADOR = c.IDCOLABORADOR