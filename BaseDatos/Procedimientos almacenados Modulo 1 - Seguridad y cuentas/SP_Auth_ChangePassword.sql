-------------------------------------------------
-- Procedimiento almacenado SP_Auth_ChangePassword
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento que permite realizar el cambio de contraseña
-------------------------------------------------

CREATE OR ALTER PROCEDURE SP_Auth_ChangePassword
  @idColaborador  INT,
  @passwordActual NVARCHAR(200),
  @passwordNueva  NVARCHAR(200),
  @mensaje        NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    -- 1) Validar actual
    IF NOT EXISTS (
      SELECT 1 FROM USUARIO
      WHERE IDCOLABORADOR = @idColaborador AND CONTRASEÑA = @passwordActual
    )
    BEGIN
      SET @mensaje = N'La contraseña actual no es válida.';
      RETURN;
    END

    -- 2) Política de contraseña
    IF LEN(@passwordNueva) < 8
       OR @passwordNueva NOT LIKE '%[A-Z]%'
       OR @passwordNueva NOT LIKE '%[a-z]%'
       OR @passwordNueva NOT LIKE '%[0-9]%'
       OR @passwordNueva NOT LIKE '%[^A-Za-z0-9 ]%'
       OR CHARINDEX(' ', @passwordNueva) > 0
    BEGIN
      SET @mensaje = N'La nueva contraseña no cumple la política.';
      RETURN;
    END

    -- 3) Actualizar
    UPDATE USUARIO
       SET CONTRASEÑA = @passwordNueva,
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDCOLABORADOR = @idColaborador;

    SET @mensaje = N'Contraseña actualizada correctamente.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al cambiar la contraseña.';
    EXEC SP_Bitacora_LogError N'Auth_ChangePassword', ERROR_MESSAGE;
  END CATCH
END
GO
/*
Seccion de pruebas
*/

-- PRUEBA 1: Actual incorrecta -> Debe NO actualizar
DECLARE @idColab INT, @msg NVARCHAR(200);

-- Asegurar colaborador de prueba
IF NOT EXISTS (SELECT 1 FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com')
INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
VALUES (N'Prueba', N'ChangePass', N'cp@test.com', N'7000-0000', N'Colaborador', 1);

SELECT @idColab = IDCOLABORADOR FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com';

-- Asegurar fila en USUARIO
IF NOT EXISTS (SELECT 1 FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab)
  INSERT INTO dbo.USUARIO (IDCOLABORADOR, CONTRASEÑA) VALUES (@idColab, N'Old#Pass1');

-- Resetear password base
UPDATE dbo.USUARIO SET CONTRASEÑA = N'Old#Pass1', FECHA_ACTUALIZACION = NULL WHERE IDCOLABORADOR = @idColab;

-- Ejecutar SP: contraseña actual incorrecta
EXEC dbo.SP_Auth_ChangePassword
     @idColaborador  = @idColab,
     @passwordActual = N'Xx#NoEs',
     @passwordNueva  = N'New#Pass1',
     @mensaje        = @msg OUTPUT;

-- Salida limpia
SELECT 'Escenario 1' AS Caso, @msg AS MensajeSP;
SELECT IDCOLABORADOR, CONTRASEÑA, FECHA_ACTUALIZACION FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab;

/*Seccion de pruebas 2*/

-- PRUEBA 2: Nueva contraseña NO cumple política (sin mayúscula)
DECLARE @idColab INT, @msg NVARCHAR(200);

IF NOT EXISTS (SELECT 1 FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com')
INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
VALUES (N'Prueba', N'ChangePass', N'cp@test.com', N'7000-0000', N'Colaborador', 1);

SELECT @idColab = IDCOLABORADOR FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com';

IF NOT EXISTS (SELECT 1 FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab)
  INSERT INTO dbo.USUARIO (IDCOLABORADOR, CONTRASEÑA) VALUES (@idColab, N'Old#Pass1');

UPDATE dbo.USUARIO SET CONTRASEÑA = N'Old#Pass1', FECHA_ACTUALIZACION = NULL WHERE IDCOLABORADOR = @idColab;

-- Ejecutar SP: nueva contraseña sin mayúscula
EXEC dbo.SP_Auth_ChangePassword
     @idColaborador  = @idColab,
     @passwordActual = N'Old#Pass1',
     @passwordNueva  = N'newpass1#',  -- inválida por política
     @mensaje        = @msg OUTPUT;

SELECT 'Escenario 2' AS Caso, @msg AS MensajeSP;
SELECT IDCOLABORADOR, CONTRASEÑA, FECHA_ACTUALIZACION FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab;

/*Seccion de pruebas 3*/

-- PRUEBA 3: Nueva contraseña con ESPACIOS -> inválida
DECLARE @idColab INT, @msg NVARCHAR(200);

IF NOT EXISTS (SELECT 1 FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com')
INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
VALUES (N'Prueba', N'ChangePass', N'cp@test.com', N'7000-0000', N'Colaborador', 1);

SELECT @idColab = IDCOLABORADOR FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com';

IF NOT EXISTS (SELECT 1 FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab)
  INSERT INTO dbo.USUARIO (IDCOLABORADOR, CONTRASEÑA) VALUES (@idColab, N'Old#Pass1');

UPDATE dbo.USUARIO SET CONTRASEÑA = N'Old#Pass1', FECHA_ACTUALIZACION = NULL WHERE IDCOLABORADOR = @idColab;

-- Ejecutar SP: nueva con espacio
EXEC dbo.SP_Auth_ChangePassword
     @idColaborador  = @idColab,
     @passwordActual = N'Old#Pass1',
     @passwordNueva  = N'New #Pass1',  -- contiene espacio
     @mensaje        = @msg OUTPUT;

SELECT 'Escenario 3' AS Caso, @msg AS MensajeSP;
SELECT IDCOLABORADOR, CONTRASEÑA, FECHA_ACTUALIZACION FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab;

/*Seccion de pruebas 4*/

-- PRUEBA 4: Éxito -> Debe actualizar contraseña y fecha
DECLARE @idColab INT, @msg NVARCHAR(200);

IF NOT EXISTS (SELECT 1 FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com')
INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
VALUES (N'Prueba', N'ChangePass', N'cp@test.com', N'7000-0000', N'Colaborador', 1);

SELECT @idColab = IDCOLABORADOR FROM dbo.COLABORADORES WHERE CORREO = 'cp@test.com';

IF NOT EXISTS (SELECT 1 FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab)
  INSERT INTO dbo.USUARIO (IDCOLABORADOR, CONTRASEÑA) VALUES (@idColab, N'Old#Pass1');

UPDATE dbo.USUARIO SET CONTRASEÑA = N'Old#Pass1', FECHA_ACTUALIZACION = NULL WHERE IDCOLABORADOR = @idColab;

-- Ejecutar SP: válida (≥8, mayús, minús, dígito, especial, sin espacios)
EXEC dbo.SP_Auth_ChangePassword
     @idColaborador  = @idColab,
     @passwordActual = N'Old#Pass1',
     @passwordNueva  = N'Good#Pass9',
     @mensaje        = @msg OUTPUT;

SELECT 'Escenario 4' AS Caso, @msg AS MensajeSP;
SELECT IDCOLABORADOR, CONTRASEÑA, FECHA_ACTUALIZACION FROM dbo.USUARIO WHERE IDCOLABORADOR = @idColab;
