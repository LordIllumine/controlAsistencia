----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Asistencia_MarcarEntrada
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento para marcas asistencia (Entrada)
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Asistencia_MarcarEntrada
  @idColaborador INT,
  @fecha         DATE,
  @horaEntrada   TIME,
  @ip            NVARCHAR(50) = NULL,
  @mac           NVARCHAR(50) = NULL,
  @mensaje       NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    IF EXISTS (SELECT 1 FROM REGISTROSASISTENCIA WHERE IDCOLABORADOR=@idColaborador AND FECHA=@fecha)
    BEGIN
      SET @mensaje = N'Ya existe un registro de asistencia para este día.';
      RETURN;
    END

    INSERT INTO REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, IPREGISTRO, MACADDRESS)
    VALUES (@idColaborador, @fecha, @horaEntrada, @ip, @mac);

    SET @mensaje = N'Entrada registrada correctamente.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al marcar entrada.';
    EXEC SP_Bitacora_LogError N'Asistencia_MarcarEntrada', ERROR_MESSAGE;
  END CATCH
END
GO

----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
--
-- PRUEBA 1: Éxito con IP/MAC
--
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.asis.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  -- colaborador de prueba
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Asistencia', @correo, N'00000000', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
  DECLARE @hora  TIME = '08:00:00';
  DECLARE @ip    NVARCHAR(50) = N'10.0.0.1';
  DECLARE @mac   NVARCHAR(50) = N'AA:BB:CC:DD:EE:01';

  EXEC dbo.SP_Asistencia_MarcarEntrada
       @idColaborador=@id, @fecha=@fecha, @horaEntrada=@hora,
       @ip=@ip, @mac=@mac, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'Entrada (éxito)',
    Estado = CASE WHEN @msg LIKE N'Entrada registrada correctamente%' AND
                        EXISTS (SELECT 1 FROM dbo.REGISTROSASISTENCIA
                                WHERE IDCOLABORADOR=@id AND FECHA=@fecha
                                  AND HORAENTRADA=@hora AND IPREGISTRO=@ip AND MACADDRESS=@mac)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Registro presente con hora/IP/MAC exactos';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Entrada (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

--
-- PRUEBA 2: Duplicado en el mismo día
--
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @id INT, @m1 NVARCHAR(200), @m2 NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.asis.dup.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Duplicado', @correo, N'11111111', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
  EXEC dbo.SP_Asistencia_MarcarEntrada @id, @fecha, '08:00', NULL, NULL, @m1 OUTPUT;  -- OK
  EXEC dbo.SP_Asistencia_MarcarEntrada @id, @fecha, '09:00', NULL, NULL, @m2 OUTPUT;  -- Debe rechazar

  SELECT
    Caso   = N'Entrada (duplicado mismo día)',
    Estado = CASE WHEN @m1 LIKE N'Entrada registrada correctamente%' AND
                        @m2 LIKE N'Ya existe un registro de asistencia para este día%' AND
                        (SELECT COUNT(*) FROM dbo.REGISTROSASISTENCIA WHERE IDCOLABORADOR=@id AND FECHA=@fecha)=1
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'1ra=' + COALESCE(@m1,N'') + N' | 2da=' + COALESCE(@m2,N''),
    Verificacion = N'Conteo=1 para ese colaborador/fecha';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Entrada (duplicado mismo día)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

--
-- PRUEBA 3: Fechas distintas (dos inserciones válidas)
--
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @id INT, @m1 NVARCHAR(200), @m2 NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.asis.dias.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Dias', @correo, N'22222222', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @h TIME = '07:45:00';
  DECLARE @h2 TIME = '08:10:00';
  DECLARE @f1 DATE = CAST(GETDATE() AS DATE);
  DECLARE @f2 DATE = DATEADD(DAY, 1, @f1);

  EXEC dbo.SP_Asistencia_MarcarEntrada @id, @f1, @h,  NULL, NULL, @m1 OUTPUT; -- Día 1
  EXEC dbo.SP_Asistencia_MarcarEntrada @id, @f2, @h2, NULL, NULL, @m2 OUTPUT; -- Día 2

  SELECT
    Caso   = N'Entrada (fechas distintas)',
    Estado = CASE WHEN @m1 LIKE N'Entrada registrada correctamente%' AND
                        @m2 LIKE N'Entrada registrada correctamente%' AND
                        (SELECT COUNT(*) FROM dbo.REGISTROSASISTENCIA WHERE IDCOLABORADOR=@id AND FECHA IN (@f1,@f2))=2
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = N'Día1=' + COALESCE(@m1,N'') + N' | Día2=' + COALESCE(@m2,N''),
    Verificacion = N'Hay dos filas (una por cada fecha)';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Entrada (fechas distintas)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

--
-- PRUEBA 4: IP/MAC NULL
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @id INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150) = N'test.asis.null.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Nulls', @correo, N'33333333', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @f DATE = CAST(GETDATE() AS DATE);
  EXEC dbo.SP_Asistencia_MarcarEntrada @id, @f, '08:30', NULL, NULL, @msg OUTPUT;

  SELECT
    Caso   = N'Entrada (IP/MAC NULL)',
    Estado = CASE WHEN @msg LIKE N'Entrada registrada correctamente%' AND
                        EXISTS(SELECT 1 FROM dbo.REGISTROSASISTENCIA
                               WHERE IDCOLABORADOR=@id AND FECHA=@f AND IPREGISTRO IS NULL AND MACADDRESS IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Campos IPREGISTRO y MACADDRESS quedaron NULL';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Entrada (IP/MAC NULL)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;


--
-- PRUEBA 5: Colaborador inexistente (espera error controlado)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @msg NVARCHAR(200);
  DECLARE @hoy DATE = CAST(GETDATE() AS DATE);  -- evita el CAST dentro del EXEC

  EXEC dbo.SP_Asistencia_MarcarEntrada
       @idColaborador = -1,
       @fecha         = @hoy,
       @horaEntrada   = '09:00',
       @ip            = NULL,
       @mac           = NULL,
       @mensaje       = @msg OUTPUT;

  SELECT
    Caso         = N'Entrada (colaborador inexistente)',
    Estado       = CASE WHEN @msg LIKE N'Error al marcar entrada%' 
                         OR @msg LIKE N'Credenciales%'  -- por si tu SP retorna texto similar
                        THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = CASE WHEN EXISTS (SELECT 1 
                                     FROM dbo.REGISTROSASISTENCIA 
                                     WHERE IDCOLABORADOR = -1 AND FECHA = @hoy)
                        THEN N'FALLO: se insertó registro'
                        ELSE N'OK: no se insertó nada' END;

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Entrada (colaborador inexistente)' AS Caso,
         N'FALLO' AS Estado,
         ERROR_MESSAGE() AS Mensaje,
         N'TRAN revertida' AS Verificacion;
END CATCH;
*/