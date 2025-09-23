----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Reporte_HorasTrabajadas
-- Author: Damian Alvarado Avilés
-- Fecha: 03/09/2025
-- Procedimiento para ver las horas trabajadas por colaborador
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Reporte_HorasTrabajadas
  @desde DATE,
  @hasta DATE,
  @idColaborador INT = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT r.IDCOLABORADOR
       , SUM(CASE WHEN r.HORAENTRADA IS NOT NULL AND r.HORASALIDA IS NOT NULL
                  THEN DATEDIFF(MINUTE, r.HORAENTRADA, r.HORASALIDA) ELSE 0 END) AS MINUTOS_BRUTOS
  FROM REGISTROSASISTENCIA r
  WHERE r.FECHA BETWEEN @desde AND @hasta
    AND (@idColaborador IS NULL OR r.IDCOLABORADOR = @idColaborador)
  GROUP BY r.IDCOLABORADOR;
END
GO
----------------------------------------------------------------------------------------------------
-- Prueba
----------------------------------------------------------------------------------------------------
/*
-- PRUEBA ÚNICA: suma de minutos brutos con filtro por colaborador (espera 720)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- 1) Semilla: colaborador
  DECLARE @idCol INT;
  DECLARE @correo NVARCHAR(150) = N'test.reporte.horas.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Horas', @correo, N'0', N'USER', 1);
  SET @idCol = SCOPE_IDENTITY();

  -- 2) Fechas dentro del rango
  DECLARE @d1 DATE = CAST(GETDATE() AS DATE);
  DECLARE @d2 DATE = DATEADD(DAY, 1, @d1);
  DECLARE @d3 DATE = DATEADD(DAY, 2, @d1);

  -- 3) Registros de asistencia:
  --    Día 1: 08:00-16:00 = 480 min
  --    Día 2: 09:00-13:00 = 240 min
  --    Día 3: incompleto (no debe sumar)
  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, HORASALIDA)
  VALUES (@idCol, @d1, '08:00', '16:00'),
         (@idCol, @d2, '09:00', '13:00'),
         (@idCol, @d3, '08:00', NULL);

  -- 4) Ejecutar SP y capturar resultado
  CREATE TABLE #r (IDCOLABORADOR INT, MINUTOS_BRUTOS INT);
  INSERT INTO #r
  EXEC dbo.SP_Reporte_HorasTrabajadas @desde=@d1, @hasta=@d3, @idColaborador=@idCol;

  -- 5) Verificación (debe haber 1 fila con 720)
  SELECT
    Caso   = N'Reporte_HorasTrabajadas (filtro por colaborador)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #r)=1
                       AND EXISTS(SELECT 1 FROM #r WHERE IDCOLABORADOR=@idCol AND MINUTOS_BRUTOS=720)
                  THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Filas=', (SELECT COUNT(*) FROM #r),
                     N' | Minutos esperados=720, devueltos=',
                     (SELECT TOP 1 MINUTOS_BRUTOS FROM #r));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Reporte_HorasTrabajadas (filtro por colaborador)' AS Caso,
         N'FALLO' AS Estado,
         ERROR_MESSAGE() AS Detalle;
END CATCH;
*/