----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Asistencia_GetByRango
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento Lista las asistencias del colaborador o las horas que ha trabajado en un rango de fechas
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Asistencia_GetByRango
  @idColaborador INT = NULL,
  @desde DATE,
  @hasta DATE
AS
BEGIN
  SET NOCOUNT ON;
  SELECT IDREGISTRO AS REGISTRO, IDCOLABORADOR AS IDENTIFICADOR, FECHA,HORAENTRADA AS [HORA DE ENTRADA], HORASALIDA AS [HORA DE SALIDA],
         IPREGISTRO AS [IP REGISTRO], MACADDRESS AS [MAC ADDRESS], FECHA_CREACION AS [CREACION], FECHA_ACTUALIZACION AS [ACTUALIZACION]
  FROM REGISTROSASISTENCIA
  WHERE FECHA BETWEEN @desde AND @hasta
    AND (@idColaborador IS NULL OR IDCOLABORADOR = @idColaborador)
  ORDER BY FECHA;
END
GO

CREATE OR ALTER PROCEDURE SP_Asistencia_ResumenHoras
  @idColaborador INT = NULL,
  @desde DATE,
  @hasta DATE
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    r.IDCOLABORADOR,
    SUM(CASE WHEN r.HORAENTRADA IS NOT NULL AND r.HORASALIDA IS NOT NULL
             THEN DATEDIFF(MINUTE, r.HORAENTRADA, r.HORASALIDA) ELSE 0 END) AS MINUTOS_TRABAJADOS
  FROM REGISTROSASISTENCIA r
  WHERE r.FECHA BETWEEN @desde AND @hasta
    AND (@idColaborador IS NULL OR r.IDCOLABORADOR = @idColaborador)
  GROUP BY r.IDCOLABORADOR;
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
-- 1

-- GETBYRANGO A: por colaborador y rango (espera 2 filas)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @pref NVARCHAR(150) = N'test.rango.a.' + CONVERT(NVARCHAR(36), NEWID());
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'A',N'Rango', @pref+N'@ex.com', N'0', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @d1 DATE = CAST(GETDATE() AS DATE);
  DECLARE @d2 DATE = DATEADD(DAY, 1, @d1);
  DECLARE @d3 DATE = DATEADD(DAY, 2, @d1);

  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR,FECHA,HORAENTRADA,HORASALIDA)
  VALUES (@id,@d1,'08:00','17:00'), (@id,@d2,'08:30','17:15'), (@id,@d3,'09:00',NULL);

  -- captura del resultado
  SELECT TOP 0 * INTO #t FROM dbo.REGISTROSASISTENCIA;
  INSERT INTO #t EXEC dbo.SP_Asistencia_GetByRango @idColaborador=@id, @desde=@d1, @hasta=@d2;

  SELECT 'GetByRango A' AS Caso,
         CASE WHEN (SELECT COUNT(*) FROM #t)=2
                   AND NOT EXISTS(SELECT 1 FROM #t WHERE FECHA NOT IN (@d1,@d2))
              THEN 'OK' ELSE 'FALLO' END AS Estado,
         CONCAT('Filas=', (SELECT COUNT(*) FROM #t), ' | Fechas esperadas: ', CONVERT(nvarchar(10),@d1,120),' y ',CONVERT(nvarchar(10),@d2,120)) AS Detalle;

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT 'GetByRango A' AS Caso, 'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;

--

-- GETBYRANGO A: por colaborador y rango (espera 2 filas)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @pref NVARCHAR(150) = N'test.rango.a.' + CONVERT(NVARCHAR(36), NEWID());
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'A',N'Rango', @pref+N'@ex.com', N'0', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @d1 DATE = CAST(GETDATE() AS DATE);
  DECLARE @d2 DATE = DATEADD(DAY, 1, @d1);
  DECLARE @d3 DATE = DATEADD(DAY, 2, @d1);

  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR,FECHA,HORAENTRADA,HORASALIDA)
  VALUES (@id,@d1,'08:00','17:00'), (@id,@d2,'08:30','17:15'), (@id,@d3,'09:00',NULL);

  -- captura del resultado
  SELECT TOP 0 * INTO #t FROM dbo.REGISTROSASISTENCIA;
  INSERT INTO #t EXEC dbo.SP_Asistencia_GetByRango @idColaborador=@id, @desde=@d1, @hasta=@d2;

  SELECT 'GetByRango A' AS Caso,
         CASE WHEN (SELECT COUNT(*) FROM #t)=2
                   AND NOT EXISTS(SELECT 1 FROM #t WHERE FECHA NOT IN (@d1,@d2))
              THEN 'OK' ELSE 'FALLO' END AS Estado,
         CONCAT('Filas=', (SELECT COUNT(*) FROM #t), ' | Fechas esperadas: ', CONVERT(nvarchar(10),@d1,120),' y ',CONVERT(nvarchar(10),@d2,120)) AS Detalle;

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT 'GetByRango A' AS Caso, 'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;

--

-- GETBYRANGO C: @idColaborador = NULL (trae a todos)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @pref NVARCHAR(150) = N'test.rango.c.' + CONVERT(NVARCHAR(36), NEWID());
  DECLARE @d DATE = CAST(GETDATE() AS DATE);

  DECLARE @id1 INT, @id2 INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'C1',N'Rango',@pref+N'1@ex.com',N'0',N'USER',1);
  SET @id1 = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'C2',N'Rango',@pref+N'2@ex.com',N'0',N'ADMIN',1);
  SET @id2 = SCOPE_IDENTITY();

  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR,FECHA,HORAENTRADA,HORASALIDA)
  VALUES (@id1,@d,'08:00','16:00'), (@id2,@d,'09:00','17:00');

  SELECT TOP 0 * INTO #t FROM dbo.REGISTROSASISTENCIA;
  INSERT INTO #t EXEC dbo.SP_Asistencia_GetByRango @idColaborador=NULL, @desde=@d, @hasta=@d;

  SELECT 'GetByRango C' AS Caso,
         CASE WHEN (SELECT COUNT(*) FROM #t)=2
              THEN 'OK' ELSE 'FALLO' END AS Estado,
         CONCAT('Filas=',(SELECT COUNT(*) FROM #t),' (dos colaboradores)') AS Detalle;

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT 'GetByRango C' AS Caso, 'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;

--

-- RESUMENHORAS D: minutos válidos + registro incompleto (=0)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @id INT, @pref NVARCHAR(150)=N'test.resumen.d.'+CONVERT(NVARCHAR(36),NEWID());
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'D',N'Resumen',@pref+N'@ex.com',N'0',N'USER',1);
  SET @id = SCOPE_IDENTITY();

  DECLARE @d1 DATE = CAST(GETDATE() AS DATE);
  DECLARE @d2 DATE = DATEADD(DAY,1,@d1);

  -- 9 horas = 540 min (08:00-17:00) + un registro incompleto (=0)
  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR,FECHA,HORAENTRADA,HORASALIDA)
  VALUES (@id,@d1,'08:00','17:00'), (@id,@d2,'09:00',NULL);

  CREATE TABLE #r (IDCOLABORADOR INT, MINUTOS_TRABAJADOS INT);
  INSERT INTO #r EXEC dbo.SP_Asistencia_ResumenHoras @idColaborador=@id, @desde=@d1, @hasta=@d2;

  SELECT 'ResumenHoras D' AS Caso,
         CASE WHEN EXISTS(SELECT 1 FROM #r WHERE IDCOLABORADOR=@id AND MINUTOS_TRABAJADOS=540)
              THEN 'OK' ELSE 'FALLO' END AS Estado,
         (SELECT CONCAT('Minutos=',MINUTOS_TRABAJADOS) FROM #r WHERE IDCOLABORADOR=@id) AS Detalle;

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT 'ResumenHoras D' AS Caso, 'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;

--

-- RESUMENHORAS F: filtro por colaborador (solo 1 fila)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  DECLARE @pref NVARCHAR(150)=N'test.resumen.f.'+CONVERT(NVARCHAR(36),NEWID());
  DECLARE @id1 INT, @id2 INT;
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'F1',N'Resumen',@pref+N'1@ex.com',N'0',N'USER',1);
  SET @id1 = SCOPE_IDENTITY();
  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'F2',N'Resumen',@pref+N'2@ex.com',N'0',N'USER',1);
  SET @id2 = SCOPE_IDENTITY();

  DECLARE @d DATE = CAST(GETDATE() AS DATE);
  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR,FECHA,HORAENTRADA,HORASALIDA)
  VALUES (@id1,@d,'08:00','17:00'), (@id2,@d,'08:00','16:00');

  CREATE TABLE #r (IDCOLABORADOR INT, MINUTOS_TRABAJADOS INT);
  INSERT INTO #r EXEC dbo.SP_Asistencia_ResumenHoras @idColaborador=@id1, @desde=@d, @hasta=@d;

  SELECT 'ResumenHoras F' AS Caso,
         CASE WHEN (SELECT COUNT(*) FROM #r)=1 AND EXISTS(SELECT 1 FROM #r WHERE IDCOLABORADOR=@id1 AND MINUTOS_TRABAJADOS=540)
              THEN 'OK' ELSE 'FALLO' END AS Estado,
         CONCAT('Filas=',(SELECT COUNT(*) FROM #r),' | Minutos=',(SELECT MINUTOS_TRABAJADOS FROM #r WHERE IDCOLABORADOR=@id1)) AS Detalle;

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT 'ResumenHoras F' AS Caso, 'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;

*/
