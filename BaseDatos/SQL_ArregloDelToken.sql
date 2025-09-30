--PASO 1
CREATE TABLE dbo.RECUPERACION_TOKENS (
  IDRECUPERACION INT IDENTITY(1,1) PRIMARY KEY,
  IDCOLABORADOR   INT           NOT NULL,
  TOKEN_HASH      VARBINARY(32) NOT NULL,
  FECHA_CREACION  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
  FECHA_EXPIRACION DATETIME2    NULL,
  USADO           BIT           NOT NULL DEFAULT 0,
  FECHA_USO       DATETIME2     NULL,
  IP               NVARCHAR(50) NULL,
  OBSERVACIONES    NVARCHAR(250) NULL
);
GO
--PASO 2
CREATE OR ALTER PROCEDURE dbo.SP_Auth_ResetPassword_Request
  @correo NVARCHAR(150),
  @token  NVARCHAR(200) OUT,   -- token en claro (para enviar por correo)
  @mensaje NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @id INT;
    SELECT @id = c.IDCOLABORADOR
      FROM dbo.COLABORADORES c
     WHERE c.CORREO = @correo AND c.ESTADO = 1;

    IF @id IS NULL
    BEGIN
      SET @mensaje = N'Correo no registrado o usuario inactivo.';
      RETURN;
    END

    -- Generar token seguro (único)
    DECLARE @tokenPlain NVARCHAR(200) = LOWER(CONVERT(NVARCHAR(36), NEWID())) + '-' + LOWER(CONVERT(NVARCHAR(36), NEWID()));
    DECLARE @tokenHash VARBINARY(32) = HASHBYTES('SHA2_256', @tokenPlain);

    -- Insertar registro persistente (ejemplo: expiración 24 horas)
    INSERT INTO dbo.RECUPERACION_TOKENS (IDCOLABORADOR, TOKEN_HASH, FECHA_CREACION, FECHA_EXPIRACION, USADO)
    VALUES (@id, @tokenHash, SYSDATETIME(), DATEADD(HOUR, 24, SYSDATETIME()), 0);

    SET @token = @tokenPlain;               -- para devolver y enviar por correo
    SET @mensaje = N'Token de recuperación generado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al solicitar recuperación.';
    EXEC dbo.SP_Bitacora_LogError N'Auth_ResetPassword_Request', ERROR_MESSAGE;
  END CATCH
END
GO
-- PASO 3
CREATE OR ALTER PROCEDURE dbo.SP_Auth_ResetPassword_Validate
  @token NVARCHAR(200),
  @idColaborador INT OUT,
  @idRecuperacion INT OUT,
  @mensaje NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @hash VARBINARY(32) = HASHBYTES('SHA2_256', @token);

    SELECT TOP 1
           @idRecuperacion = r.IDRECUPERACION,
           @idColaborador  = r.IDCOLABORADOR
    FROM dbo.RECUPERACION_TOKENS r
    WHERE r.TOKEN_HASH = @hash
      AND r.USADO = 0
      AND (r.FECHA_EXPIRACION IS NULL OR r.FECHA_EXPIRACION >= SYSDATETIME());

    IF @idRecuperacion IS NULL
    BEGIN
      SET @mensaje = N'Token inválido, expirado o ya usado.';
      RETURN;
    END

    SET @mensaje = N'Token válido.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al validar token.';
    EXEC dbo.SP_Bitacora_LogError N'Auth_ResetPassword_Validate', ERROR_MESSAGE;
  END CATCH
END
GO
--PASO 4
CREATE OR ALTER PROCEDURE dbo.SP_Auth_ResetPassword_ConfirmToken
  @token NVARCHAR(200),
  @passwordNueva NVARCHAR(200),
  @mensaje NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @hash VARBINARY(32) = HASHBYTES('SHA2_256', @token);
    DECLARE @idRec INT, @idCol INT;

    SELECT TOP 1 @idRec = r.IDRECUPERACION, @idCol = r.IDCOLABORADOR
    FROM dbo.RECUPERACION_TOKENS r
    WHERE r.TOKEN_HASH = @hash
      AND r.USADO = 0
      AND (r.FECHA_EXPIRACION IS NULL OR r.FECHA_EXPIRACION >= SYSDATETIME());

    IF @idRec IS NULL
    BEGIN
      SET @mensaje = N'Token inválido, expirado o ya usado.';
      RETURN;
    END

    -- Política de contraseña
    IF LEN(@passwordNueva) < 8
       OR @passwordNueva NOT LIKE '%[A-Z]%'
       OR @passwordNueva NOT LIKE '%[a-z]%'
       OR @passwordNueva NOT LIKE '%[0-9]%'
       OR @passwordNueva NOT LIKE '%[^A-Za-z0-9]%'  -- algún carácter especial
       OR CHARINDEX(' ', @passwordNueva) > 0
    BEGIN
      SET @mensaje = N'La nueva contraseña no cumple la política.';
      RETURN;
    END

    -- Actualizar contraseña (tabla USUARIO: columna CONTRASEÑA)
    UPDATE dbo.USUARIO
      SET CONTRASEÑA = @passwordNueva,
          FECHA_ACTUALIZACION = GETDATE()
    WHERE IDCOLABORADOR = @idCol;

    IF @@ROWCOUNT = 0
    BEGIN
      SET @mensaje = N'Usuario no encontrado.';
      RETURN;
    END

    -- Marcar token como usado (auditoría)
    UPDATE dbo.RECUPERACION_TOKENS
      SET USADO = 1, FECHA_USO = SYSDATETIME()
    WHERE IDRECUPERACION = @idRec;

    SET @mensaje = N'Contraseña restablecida correctamente.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al restablecer la contraseña.';
    EXEC dbo.SP_Bitacora_LogError N'Auth_ResetPassword_ConfirmToken', ERROR_MESSAGE;
  END CATCH
END
GO
-- PASO 5 PRUEBA
/*
-- PRUEBA: flujo completo (REQUEST -> VALIDATE -> CONFIRM) sin dejar datos
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @correo NVARCHAR(150), @token NVARCHAR(200), @msg NVARCHAR(200);
  DECLARE @oldPass NVARCHAR(200) = N'Inicio1!A';

  -- 1) Crear colaborador + usuario
  SET @correo = N'test.flow.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Prueba', N'Flow', @correo, N'00000000', N'USER', 1);
  SET @idCol = SCOPE_IDENTITY();

  INSERT INTO dbo.USUARIO (IDCOLABORADOR, CONTRASEÑA) VALUES (@idCol, @oldPass);

  -- 2) Request -> genera token persistente y lo devuelve en @token
  EXEC dbo.SP_Auth_ResetPassword_Request @correo=@correo, @token=@token OUTPUT, @mensaje=@msg OUTPUT;
  SELECT 'REQUEST' AS Paso, @token AS Token, @msg AS Mensaje;

  -- 3) Validar token
  DECLARE @idColVal INT, @idRec INT, @msgVal NVARCHAR(200);
  EXEC dbo.SP_Auth_ResetPassword_Validate @token=@token, @idColaborador=@idColVal OUTPUT, @idRecuperacion=@idRec OUTPUT, @mensaje=@msgVal OUTPUT;
  SELECT 'VALIDATE' AS Paso, @idColVal AS IdColaborador, @idRec AS IdRecuperacion, @msgVal AS Mensaje;

  -- 4) Confirmar con nueva contraseña válida
  DECLARE @newPass NVARCHAR(200) = N'NewPass1!A';
  DECLARE @msgConf NVARCHAR(200);
  EXEC dbo.SP_Auth_ResetPassword_ConfirmToken @token=@token, @passwordNueva=@newPass, @mensaje=@msgConf OUTPUT;
  SELECT 'CONFIRM' AS Paso, @msgConf AS Mensaje;

  -- 5) Verificaciones internas (tabla USUARIO y RECUPERACION_TOKENS)
  SELECT 'USUARIO' AS OBJ, IDCOLABORADOR, CONTRASEÑA, FECHA_ACTUALIZACION FROM dbo.USUARIO WHERE IDCOLABORADOR=@idCol;
  SELECT 'TOKEN_ROW' AS OBJ, * FROM dbo.RECUPERACION_TOKENS WHERE IDRECUPERACION=@idRec;

  ROLLBACK; -- no dejamos rastro
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT ERROR_MESSAGE() AS Error;
END CATCH;
*/
GO
-- PASO 6 Reglas operativas / recomendaciones finales
/*
No mandar el token en claro en producción: envíalo por correo y muestra sólo un mensaje “Se envió un enlace a tu correo”.

Guardar sólo hash en BD (como hice arriba).

Expiración: 24 horas por defecto; puedes ajustar y crear job para borrar tokens antiguos.

Revocación: añade un SP para invalidar tokens manualmente si lo necesitas (update USADO=1). (ESTO NO SE SI HACERLO)
*/
