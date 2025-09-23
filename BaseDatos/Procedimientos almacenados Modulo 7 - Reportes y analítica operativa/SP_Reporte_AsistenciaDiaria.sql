----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Reporte_AsistenciaDiaria
-- Author: Damian Alvarado Avilés
-- Fecha: 03/09/2025
-- Procedimiento para ver las asistencias de los colaboradores en una fecha especifica
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Reporte_AsistenciaDiaria
  @fecha DATE
AS
BEGIN
  SET NOCOUNT ON;
  SELECT c.IDCOLABORADOR, c.NOMBRE, c.APELLIDO, r.HORAENTRADA, r.HORASALIDA
  FROM COLABORADORES c
  LEFT JOIN REGISTROSASISTENCIA r
    ON r.IDCOLABORADOR = c.IDCOLABORADOR AND r.FECHA = @fecha;
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
----------------------------------------------------------------------------------------------------
-- Prueba 1
----------------------------------------------------------------------------------------------------
-- REPORTE_DIA - PRUEBA 1 (uno con registro y otro sin)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

  -- Semillas
  DECLARE @idCon INT, @idSin INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Ana', N'Con', N'ana.con@ex.com', N'0', N'USER', 1);
  SET @idCon = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Bruno', N'Sin', N'bruno.sin@ex.com', N'0', N'USER', 1);
  SET @idSin = SCOPE_IDENTITY();

  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, HORASALIDA)
  VALUES (@idCon, @hoy, '08:00', '17:00');

  -- Captura del resultado
  CREATE TABLE #t (
    IDCOLABORADOR INT,
    NOMBRE NVARCHAR(200),
    APELLIDO NVARCHAR(200),
    HORAENTRADA TIME NULL,
    HORASALIDA  TIME NULL
  );
  INSERT INTO #t EXEC dbo.SP_Reporte_AsistenciaDiaria @fecha=@hoy;

  SELECT
    Caso   = N'Reporte diario (mixto)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t WHERE IDCOLABORADOR IN (@idCon, @idSin)) = 2
                        AND EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR=@idCon AND HORAENTRADA='08:00' AND HORASALIDA='17:00')
                        AND EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR=@idSin AND HORAENTRADA IS NULL AND HORASALIDA IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Total filas (todos los cols)=', (SELECT COUNT(*) FROM #t),
                     N' | Con-registro OK y Sin-registro NULL');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Reporte diario (mixto)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 2
----------------------------------------------------------------------------------------------------
-- REPORTE_DIA - PRUEBA 2 (múltiples registros en el día)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

  DECLARE @id INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Carla', N'Doble', N'carla.doble@ex.com', N'0', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, HORASALIDA)
  VALUES (@id, @hoy, '08:00', '10:00'),
         (@id, @hoy, '14:00', '18:00');

  CREATE TABLE #t (
    IDCOLABORADOR INT, NOMBRE NVARCHAR(200), APELLIDO NVARCHAR(200),
    HORAENTRADA TIME NULL, HORASALIDA TIME NULL
  );
  INSERT INTO #t EXEC dbo.SP_Reporte_AsistenciaDiaria @fecha=@hoy;

  SELECT
    Caso   = N'Reporte diario (múltiples registros)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t WHERE IDCOLABORADOR=@id)=2
                        AND EXISTS(SELECT 1 FROM #t WHERE HORAENTRADA='08:00' AND HORASALIDA='10:00' AND IDCOLABORADOR=@id)
                        AND EXISTS(SELECT 1 FROM #t WHERE HORAENTRADA='14:00' AND HORASALIDA='18:00' AND IDCOLABORADOR=@id)
                   THEN N'OK' ELSE N'FALLO' END,
    Detalle = N'Devuelve una fila por cada registro en REGISTROSASISTENCIA';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Reporte diario (múltiples registros)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 3
----------------------------------------------------------------------------------------------------
-- REPORTE_DIA - PRUEBA 3 (sin registros en la fecha consultada)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @hoy DATE   = CAST(GETDATE() AS DATE);
  DECLARE @ayer DATE  = DATEADD(DAY, -1, @hoy);

  DECLARE @id1 INT, @id2 INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Diego', N'SR', N'diego.sr@ex.com', N'0', N'USER', 1);
  SET @id1 = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Elena', N'SR', N'elena.sr@ex.com', N'0', N'USER', 1);
  SET @id2 = SCOPE_IDENTITY();

  -- Registros el día anterior (no deberían aparecer en @hoy)
  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, HORASALIDA)
  VALUES (@id1, @ayer, '08:00', '17:00'),
         (@id2, @ayer, '09:00', '18:00');

  CREATE TABLE #t (
    IDCOLABORADOR INT, NOMBRE NVARCHAR(200), APELLIDO NVARCHAR(200),
    HORAENTRADA TIME NULL, HORASALIDA TIME NULL
  );
  INSERT INTO #t EXEC dbo.SP_Reporte_AsistenciaDiaria @fecha=@hoy;

  SELECT
    Caso   = N'Reporte diario (sin registros en la fecha)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t WHERE IDCOLABORADOR IN (@id1,@id2))=2
                        AND NOT EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR IN (@id1,@id2)
                                       AND (HORAENTRADA IS NOT NULL OR HORASALIDA IS NOT NULL))
                   THEN N'OK' ELSE N'FALLO' END,
    Detalle = N'Todos los colaboradores aparecen con horas NULL para la fecha consultada';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Reporte diario (sin registros en la fecha)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
----------------------------------------------------------------------------------------------------
-- Prueba 4
----------------------------------------------------------------------------------------------------
-- REPORTE_DIA - PRUEBA 4 (incluye colaboradores inactivos)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

  DECLARE @idAct INT, @idIna INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Fabi', N'Activa', N'fabi.act@ex.com', N'0', N'USER', 1);
  SET @idAct = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Gabo', N'Inactivo', N'gabo.inac@ex.com', N'0', N'USER', 0);
  SET @idIna = SCOPE_IDENTITY();

  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, HORASALIDA)
  VALUES (@idAct, @hoy, '08:30', '17:30');

  CREATE TABLE #t (
    IDCOLABORADOR INT, NOMBRE NVARCHAR(200), APELLIDO NVARCHAR(200),
    HORAENTRADA TIME NULL, HORASALIDA TIME NULL
  );
  INSERT INTO #t EXEC dbo.SP_Reporte_AsistenciaDiaria @fecha=@hoy;

  SELECT
    Caso   = N'Reporte diario (incluye inactivos)',
    Estado = CASE WHEN EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR=@idAct AND HORAENTRADA='08:30' AND HORASALIDA='17:30')
                        AND EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR=@idIna AND HORAENTRADA IS NULL AND HORASALIDA IS NULL)
                   THEN N'OK' ELSE N'FALLO' END,
    Detalle = N'Aparece activo con horas y también inactivo con horas NULL';

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Reporte diario (incluye inactivos)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
*/