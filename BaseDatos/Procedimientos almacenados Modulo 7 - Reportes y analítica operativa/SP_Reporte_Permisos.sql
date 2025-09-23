----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Reporte_Permisos
-- Author: Damian Alvarado Avilés
-- Fecha: 03/09/2025
-- Procedimiento para ver todos los permisos segun su estado
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Reporte_Permisos
  @desde DATE,
  @hasta DATE,
  @estado NVARCHAR(50) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT *
  FROM PERMISOS
  WHERE FECHASOLICITUD BETWEEN @desde AND @hasta
    AND (@estado IS NULL OR ESTADO = @estado);
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
-- PRUEBA: Reporte_Permisos (rango + estado = 'Aprobado')
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  -- 1) Semilla: colaborador
  DECLARE @idCol INT;
  DECLARE @correo NVARCHAR(150)=N'test.rep.perm.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';
  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'ReportePermisos', @correo, N'0', N'USER', 1);
  SET @idCol = SCOPE_IDENTITY();

  -- 2) Rango de consulta (fechas sin hora)
  DECLARE @desde DATE = CAST(GETDATE() AS DATE);
  DECLARE @medio DATE = DATEADD(DAY, 1, @desde);
  DECLARE @hasta DATE = DATEADD(DAY, 2, @desde);

  -- 3) Fechas de solicitud exactas (00:00) para evitar ambigüedad con DATE
  DECLARE @sol1 DATETIME = CAST(@desde AS DATETIME);         -- = @desde (borde inferior)
  DECLARE @sol2 DATETIME = CAST(@medio AS DATETIME);         -- dentro
  DECLARE @sol3 DATETIME = CAST(@hasta AS DATETIME);         -- = @hasta (borde superior)
  DECLARE @solFuera DATETIME = CAST(DATEADD(DAY, 3, @desde) AS DATETIME); -- fuera de rango

  -- 4) Insertar permisos de prueba
  INSERT INTO dbo.PERMISOS (IDCOLABORADOR, FECHASOLICITUD, FECHAINICIO, FECHAFIN, MOTIVO, ESTADO)
  VALUES
    (@idCol, @sol1, @sol1, DATEADD(HOUR, 2, @sol1), N'Aprobado en desde',  N'Aprobado'),
    (@idCol, @sol2, @sol2, DATEADD(HOUR, 3, @sol2), N'Pendiente dentro',   N'Pendiente'),
    (@idCol, @sol3, @sol3, DATEADD(HOUR, 4, @sol3), N'Aprobado en hasta',  N'Aprobado'),
    (@idCol, @solFuera, @solFuera, DATEADD(HOUR, 1, @solFuera), N'Aprobado fuera', N'Aprobado');

  -- 5) Ejecutar SP y capturar resultado
  SELECT TOP 0 * INTO #t FROM dbo.PERMISOS;
  INSERT INTO #t
  EXEC dbo.SP_Reporte_Permisos @desde=@desde, @hasta=@hasta, @estado=N'Aprobado';

  -- 6) Verificación
  SELECT
    Caso   = N'Reporte_Permisos (rango + estado)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=2
                        AND NOT EXISTS(SELECT 1 FROM #t WHERE ESTADO<>N'Aprobado')
                        AND (SELECT MIN(FECHASOLICITUD) FROM #t) >= CAST(@desde AS DATETIME)
                        AND (SELECT MAX(FECHASOLICITUD) FROM #t) <= CAST(@hasta AS DATETIME)
                   THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(
              N'Filas=', (SELECT COUNT(*) FROM #t),
              N' | MinFecha=', CONVERT(NVARCHAR(19),(SELECT MIN(FECHASOLICITUD) FROM #t),120),
              N' | MaxFecha=', CONVERT(NVARCHAR(19),(SELECT MAX(FECHASOLICITUD) FROM #t),120),
              N' | Solo estado=Aprobado');

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'Reporte_Permisos (rango + estado)' AS Caso,
         N'FALLO' AS Estado,
         ERROR_MESSAGE() AS Detalle;
END CATCH;
*/