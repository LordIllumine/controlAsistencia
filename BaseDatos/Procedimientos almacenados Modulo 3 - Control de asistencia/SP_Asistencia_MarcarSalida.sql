----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Asistencia_MarcarSalida
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento para marcas asistencia (Salida)
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Asistencia_MarcarSalida
  @idColaborador INT,
  @fecha         DATE,
  @horaSalida    TIME,
  @mensaje       NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @horaIn TIME;
    SELECT @horaIn = HORAENTRADA
    FROM REGISTROSASISTENCIA
    WHERE IDCOLABORADOR=@idColaborador AND FECHA=@fecha;

    IF @horaIn IS NULL
    BEGIN
      SET @mensaje = N'No existe entrada previa para hoy.';
      RETURN;
    END

    IF @horaSalida <= @horaIn
    BEGIN
      SET @mensaje = N'La hora de salida debe ser mayor que la hora de entrada.';
      RETURN;
    END

    UPDATE REGISTROSASISTENCIA
       SET HORASALIDA = @horaSalida,
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDCOLABORADOR=@idColaborador AND FECHA=@fecha;

    SET @mensaje = N'Salida registrada correctamente.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al marcar salida.';
    EXEC SP_Bitacora_LogError N'Asistencia_MarcarSalida', ERROR_MESSAGE;
  END CATCH
END
GO

----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- PRUEBA 1: Éxito (actualiza HORASALIDA)
----------------------------------------------------------------------------------------------------
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.sal.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Salida', @correo, N'00000000', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, IPREGISTRO, MACADDRESS)
  VALUES (@id, @fecha, '08:00', NULL, NULL);

  EXEC dbo.SP_Asistencia_MarcarSalida
       @idColaborador=@id, @fecha=@fecha, @horaSalida='17:15', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'MarcarSalida (éxito)',
    Estado = CASE WHEN @msg LIKE N'Salida registrada correctamente%' AND
                        EXISTS (SELECT 1 FROM dbo.REGISTROSASISTENCIA
                                WHERE IDCOLABORADOR=@id AND FECHA=@fecha AND HORASALIDA='17:15')
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'HORASALIDA actualizada a 17:15';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'MarcarSalida (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- PRUEBA 2: No hay entrada previa (rechaza)
----------------------------------------------------------------------------------------------------
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.sal.noentrada.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'SinEntrada', @correo, N'11111111', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
  EXEC dbo.SP_Asistencia_MarcarSalida
       @idColaborador=@id, @fecha=@fecha, @horaSalida='17:00', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'MarcarSalida (sin entrada previa)',
    Estado = CASE WHEN @msg LIKE N'No existe entrada previa para hoy%' AND
                        NOT EXISTS (SELECT 1 FROM dbo.REGISTROSASISTENCIA
                                    WHERE IDCOLABORADOR=@id AND FECHA=@fecha AND HORASALIDA IS NOT NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin modificaciones en REGISTROSASISTENCIA';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'MarcarSalida (sin entrada previa)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- PRUEBA 3: horaSalida <= horaEntrada (rechaza)
----------------------------------------------------------------------------------------------------
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.sal.invalida.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Invalida', @correo, N'22222222', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA)
  VALUES (@id, @fecha, '08:00');

  EXEC dbo.SP_Asistencia_MarcarSalida
       @idColaborador=@id, @fecha=@fecha, @horaSalida='07:30', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'MarcarSalida (salida ≤ entrada)',
    Estado = CASE WHEN @msg LIKE N'La hora de salida debe ser mayor que la hora de entrada%' AND
                        EXISTS (SELECT 1 FROM dbo.REGISTROSASISTENCIA
                                WHERE IDCOLABORADOR=@id AND FECHA=@fecha AND HORASALIDA IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'HORASALIDA sigue NULL';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'MarcarSalida (salida ≤ entrada)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
----------------------------------------------------------------------------------------------------
-- PRUEBA 4: Actualización posterior (aumenta HORASALIDA)
----------------------------------------------------------------------------------------------------
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @m1 NVARCHAR(200), @m2 NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.sal.update.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Upd', @correo, N'33333333', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA)
  VALUES (@id, @fecha, '08:00');

  EXEC dbo.SP_Asistencia_MarcarSalida @id, @fecha, '16:00', @m1 OUTPUT;
  EXEC dbo.SP_Asistencia_MarcarSalida @id, @fecha, '18:30', @m2 OUTPUT;

  SELECT
    Caso   = N'MarcarSalida (actualización posterior)',
    Estado = CASE WHEN @m1 LIKE N'Salida registrada correctamente%' AND
                        @m2 LIKE N'Salida registrada correctamente%' AND
                        EXISTS (SELECT 1 FROM dbo.REGISTROSASISTENCIA
                                WHERE IDCOLABORADOR=@id AND FECHA=@fecha AND HORASALIDA='18:30')
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'1ra=' + COALESCE(@m1,N'') + N' | 2da=' + COALESCE(@m2,N''),
    Verificacion = N'HORASALIDA quedó en 18:30';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'MarcarSalida (actualización posterior)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/