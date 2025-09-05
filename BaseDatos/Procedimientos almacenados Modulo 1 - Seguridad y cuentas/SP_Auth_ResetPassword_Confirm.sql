----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Auth_ResetPassword_Confirm
-- Author: Damian Alvarado Avil�s
-- Fecha: 02/09/2025
-- Procedimiento para actualizar la contrase�a
----------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE SP_Auth_ResetPassword_Confirm
  @correo         NVARCHAR(150),
  @passwordNueva  NVARCHAR(200),
  @mensaje        NVARCHAR(200) OUT
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

    -- Pol�tica
    IF LEN(@passwordNueva) < 8
       OR @passwordNueva NOT LIKE '%[A-Z]%'
       OR @passwordNueva NOT LIKE '%[a-z]%'
       OR @passwordNueva NOT LIKE '%[0-9]%'
       OR @passwordNueva NOT LIKE '%[^A-Za-z0-9 ]%'
       OR CHARINDEX(' ', @passwordNueva) > 0
    BEGIN
      SET @mensaje = N'La nueva contrase�a no cumple la pol�tica.';
      RETURN;
    END

    UPDATE USUARIO
       SET CONTRASE�A = @passwordNueva,
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDCOLABORADOR = @id;

    SET @mensaje = N'Contrase�a restablecida correctamente.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al restablecer la contrase�a.';
    EXEC SP_Bitacora_LogError N'Auth_ResetPassword_Confirm', ERROR_MESSAGE;
  END CATCH
END
GO

----------------------------------------------------------------------------------------------------
-- Secci�n de pruebas
----------------------------------------------------------------------------------------------------
/*
-- PRUEBA 1: �xito (actualiza la contrase�a)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correo NVARCHAR(150) = N'test.confirm.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @passInicial NVARCHAR(200) = N'Aa1!Inicio';
  DECLARE @passNueva   NVARCHAR(200) = N'Bb2@Nueva';

  DECLARE @id INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Ok', @correo, N'00000000', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  INSERT INTO dbo.[USUARIO] (IDCOLABORADOR, [CONTRASE�A]) VALUES (@id, @passInicial);

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Auth_ResetPassword_Confirm
       @correo=@correo, @passwordNueva=@passNueva, @mensaje=@msg OUTPUT;

  SELECT
    Caso         = N'Confirm (�xito)',
    Estado       = CASE WHEN @msg LIKE N'Contrase�a restablecida correctamente%' AND
                             EXISTS(SELECT 1 FROM dbo.[USUARIO] WHERE IDCOLABORADOR=@id AND [CONTRASE�A]=@passNueva)
                        THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'[USUARIO].[CONTRASE�A] = @passNueva';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Confirm (�xito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

-- PRUEBA 2: Usuario inactivo (debe rechazar)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correo NVARCHAR(150) = N'test.confirm.inactivo.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @passInicial NVARCHAR(200) = N'Aa1!Inicio';
  DECLARE @passNueva   NVARCHAR(200) = N'Bb2@Nueva';

  DECLARE @id INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Inactivo', @correo, N'00000000', N'USER', 0);
  SET @id = SCOPE_IDENTITY();

  INSERT INTO dbo.[USUARIO] (IDCOLABORADOR, [CONTRASE�A]) VALUES (@id, @passInicial);

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Auth_ResetPassword_Confirm
       @correo=@correo, @passwordNueva=@passNueva, @mensaje=@msg OUTPUT;

  SELECT
    Caso         = N'Confirm (inactivo)',
    Estado       = CASE WHEN @msg LIKE N'Correo no registrado o usuario inactivo%' AND
                             EXISTS(SELECT 1 FROM dbo.[USUARIO] WHERE IDCOLABORADOR=@id AND [CONTRASE�A]=@passInicial)
                        THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Contrase�a NO cambi� (sigue @passInicial)';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Confirm (inactivo)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

-- PRUEBA 3: Correo no registrado (debe rechazar)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correo NVARCHAR(150) = N'no.existe.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @msg NVARCHAR(200);

  EXEC dbo.SP_Auth_ResetPassword_Confirm
       @correo=@correo, @passwordNueva=N'Bb2@Nueva', @mensaje=@msg OUTPUT;

  SELECT
    Caso         = N'Confirm (correo no registrado)',
    Estado       = CASE WHEN @msg LIKE N'Correo no registrado o usuario inactivo%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin cambios';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Confirm (correo no registrado)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

-- PRUEBA 4: Pol�tica inv�lida (rechaza por complejidad)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @correo NVARCHAR(150) = N'test.confirm.politica.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  DECLARE @passInicial NVARCHAR(200) = N'Aa1!Inicio';
  DECLARE @passInvalida NVARCHAR(200) = N'abc12345';  -- >=8 pero sin MAY�SCULA ni especial

  DECLARE @id INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Politica', @correo, N'00000000', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  INSERT INTO dbo.[USUARIO] (IDCOLABORADOR, [CONTRASE�A]) VALUES (@id, @passInicial);

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Auth_ResetPassword_Confirm
       @correo=@correo, @passwordNueva=@passInvalida, @mensaje=@msg OUTPUT;

  SELECT
    Caso         = N'Confirm (pol�tica inv�lida)',
    Estado       = CASE WHEN @msg LIKE N'La nueva contrase�a no cumple la pol�tica%' AND
                             EXISTS(SELECT 1 FROM dbo.[USUARIO] WHERE IDCOLABORADOR=@id AND [CONTRASE�A]=@passInicial)
                        THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Contrase�a NO cambi� (sigue @passInicial)';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Confirm (pol�tica inv�lida)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/