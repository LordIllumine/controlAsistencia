USE [CONTROL_ASISTENCIA]
GO

/****** Object:  StoredProcedure [dbo].[SP_Colaborador_Create]    Script Date: 29/9/2025 21:38:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Colaborador_Create
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento que permite crear un nuevo colaborador
----------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[SP_Colaborador_Create]
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

    -- Política (corregida: el patrón para "carácter especial" NO debe incluir espacio)
    IF LEN(@password) < 8
       OR @password NOT LIKE '%[A-Z]%'       -- mayúscula
       OR @password NOT LIKE '%[a-z]%'       -- minúscula
       OR @password NOT LIKE '%[0-9]%'       -- número
       OR @password NOT LIKE '%[^A-Za-z0-9]%'-- al menos un carácter NO alfanumérico (especial)
       OR CHARINDEX(' ', @password) > 0      -- sin espacios
    BEGIN
      SET @mensaje = N'La contraseña inicial no cumple la política.';
      ROLLBACK TRAN;
      RETURN;
    END

    INSERT INTO COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
    VALUES (@nombre, @apellido, @correo, @telefono, @rol, @estado);

    SET @idColaborador = CAST(SCOPE_IDENTITY() AS INT);

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
-- PRUEBA: Ejecutar SP_Colaborador_Create y ver el @idColaborador devuelto
/*
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT = NULL;
  DECLARE @msg NVARCHAR(200) = N'';

  EXEC dbo.SP_Colaborador_Create
       @nombre = N'TestPrueba',
       @apellido = N'Usuario',
       @correo = 'test.pruebaN@example.com',
       @telefono = 71402301,
       @rol = N'USER',
       @estado = 1,
       @password = N'Aa1!passw',      -- cumple la política: mayúscula, minúsc., número, especial, >8, sin espacios
       @idColaborador = @id OUTPUT,
       @mensaje = @msg OUTPUT;

  SELECT @id AS IdDevuelto, @msg AS Mensaje;

  -- Ver si realmente existe la fila (dentro de la TRAN)
  SELECT TOP 1 IDCOLABORADOR, NOMBRE, APELLIDO, CORREO FROM COLABORADORES WHERE IDCOLABORADOR = @id;

  ROLLBACK; -- no dejamos rastro
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT ERROR_MESSAGE() AS Error;
END CATCH;
*/
