----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Asistencia_EditarRegistro
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento para editar el registro
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Asistencia_EditarRegistro
  @idRegistro  INT,
  @horaEntrada TIME = NULL,
  @horaSalida  TIME = NULL,
  @mensaje     NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @in TIME, @out TIME;
    SELECT @in = HORAENTRADA, @out = HORASALIDA
    FROM REGISTROSASISTENCIA WHERE IDREGISTRO=@idRegistro;

    IF @in IS NULL AND @horaEntrada IS NULL
    BEGIN
      SET @mensaje = N'El registro no tiene hora de entrada; proporciónala.';
      RETURN;
    END

    IF @horaEntrada IS NOT NULL AND @horaSalida IS NOT NULL AND @horaSalida <= @horaEntrada
    BEGIN
      SET @mensaje = N'La hora de salida debe ser mayor que la hora de entrada.';
      RETURN;
    END

    UPDATE REGISTROSASISTENCIA
       SET HORAENTRADA = COALESCE(@horaEntrada, HORAENTRADA),
           HORASALIDA  = COALESCE(@horaSalida, HORASALIDA),
           FECHA_ACTUALIZACION = GETDATE()
     WHERE IDREGISTRO = @idRegistro;

    IF @@ROWCOUNT = 0
      SET @mensaje = N'No se encontró el registro.';
    ELSE
      SET @mensaje = N'Registro actualizado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al editar registro.';
    EXEC SP_Bitacora_LogError N'Asistencia_EditarRegistro', ERROR_MESSAGE;
  END CATCH
END
GO

SELECT * FROM REGISTROSASISTENCIA
----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- PRUEBA 1: Éxito (setea HORASALIDA)
----------------------------------------------------------------------------------------------------
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- colaborador y registro inicial con entrada
  DECLARE @idCol INT, @idReg INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150)=N'test.edit.out.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES(N'Test',N'EditOut',@correo,N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @f DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA(IDCOLABORADOR,FECHA,HORAENTRADA) VALUES(@idCol,@f,'08:05'); 
  SET @idReg = SCOPE_IDENTITY();

  EXEC dbo.SP_Asistencia_EditarRegistro
       @idRegistro=@idReg, @horaEntrada=NULL, @horaSalida='17:10', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'EditarRegistro (salida OK)',
    Estado = CASE WHEN @msg LIKE N'Registro actualizado%' AND
                        EXISTS(SELECT 1 FROM dbo.REGISTROSASISTENCIA
                               WHERE IDREGISTRO=@idReg AND HORASALIDA='17:10' AND FECHA_ACTUALIZACION IS NOT NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'HORASALIDA=17:10 y FECHA_ACTUALIZACION <> NULL';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'EditarRegistro (salida OK)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

----------------------------------------------------------------------------------------------------
-- PRUEBA 2: horaSalida <= horaEntrada → debe rechazar
----------------------------------------------------------------------------------------------------
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idReg INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150)=N'test.edit.bad.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES(N'Test',N'BadTimes',@correo,N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @f DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA(IDCOLABORADOR,FECHA,HORAENTRADA) VALUES(@idCol,@f,'08:00');
  SET @idReg = SCOPE_IDENTITY();

  EXEC dbo.SP_Asistencia_EditarRegistro
       @idRegistro=@idReg, @horaEntrada='08:00', @horaSalida='07:59', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'EditarRegistro (salida ≤ entrada)',
    Estado = CASE WHEN @msg LIKE N'La hora de salida debe ser mayor%' AND
                        EXISTS(SELECT 1 FROM dbo.REGISTROSASISTENCIA
                               WHERE IDREGISTRO=@idReg AND HORASALIDA IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'HORASALIDA sigue NULL';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'EditarRegistro (salida ≤ entrada)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;

----------------------------------------------------------------------------------------------------
-- PRUEBA 3: registro sin entrada y @horaEntrada = NULL → debe pedir entrada
----------------------------------------------------------------------------------------------------
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idReg INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150)=N'test.edit.noin.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES(N'Test',N'NeedIn',@correo,N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @f DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA(IDCOLABORADOR,FECHA,HORAENTRADA,HORASALIDA)
  VALUES(@idCol,@f,NULL,NULL);  -- ← sin entrada
  SET @idReg = SCOPE_IDENTITY();

  EXEC dbo.SP_Asistencia_EditarRegistro
       @idRegistro=@idReg, @horaEntrada=NULL, @horaSalida='17:00', @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'EditarRegistro (requiere entrada)',
    Estado = CASE WHEN @msg LIKE N'El registro no tiene hora de entrada; proporciónala.%' AND
                        EXISTS(SELECT 1 FROM dbo.REGISTROSASISTENCIA WHERE IDREGISTRO=@idReg AND HORAENTRADA IS NULL AND HORASALIDA IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin cambios: sigue HORAENTRADA/HORASALIDA NULL';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'EditarRegistro (requiere entrada)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;


-- PRUEBA 4: completar HORAENTRADA faltante
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @idCol INT, @idReg INT, @msg NVARCHAR(200);
  DECLARE @correo NVARCHAR(150)=N'test.edit.addin.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';
  INSERT INTO dbo.COLABORADORES(NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES(N'Test',N'AddIn',@correo,N'0',N'USER',1);
  SET @idCol = SCOPE_IDENTITY();

  DECLARE @f DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA(IDCOLABORADOR,FECHA,HORAENTRADA,HORASALIDA)
  VALUES(@idCol,@f,NULL,NULL);
  SET @idReg = SCOPE_IDENTITY();

  EXEC dbo.SP_Asistencia_EditarRegistro
       @idRegistro=@idReg, @horaEntrada='09:15', @horaSalida=NULL, @mensaje=@msg OUTPUT;

  SELECT
    Caso   = N'EditarRegistro (agrega entrada)',
    Estado = CASE WHEN @msg LIKE N'Registro actualizado%' AND
                        EXISTS(SELECT 1 FROM dbo.REGISTROSASISTENCIA
                               WHERE IDREGISTRO=@idReg AND HORAENTRADA='09:15' AND HORASALIDA IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'HORAENTRADA=09:15; HORASALIDA sigue NULL';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'EditarRegistro (agrega entrada)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;


-- PRUEBA 5: ID de registro inexistente
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @msg NVARCHAR(200);
  EXEC dbo.SP_Asistencia_EditarRegistro
       @idRegistro=-1, @horaEntrada='08:00', @horaSalida=NULL, @mensaje=@msg OUTPUT;

  SELECT
    Caso         = N'EditarRegistro (ID inexistente)',
    Estado       = CASE WHEN @msg LIKE N'No se encontró el registro%' THEN N'OK' ELSE N'FALLO' END,
    Mensaje      = @msg,
    Verificacion = N'Sin cambios en REGISTROSASISTENCIA';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'EditarRegistro (ID inexistente)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Mensaje, N'TRAN revertida' AS Verificacion;
END CATCH;
*/