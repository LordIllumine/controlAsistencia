----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Reporte_Productividad
-- Author: Damian Alvarado Avilés
-- Fecha: 03/09/2025
-- Para ver la productividad de los empleados (horas trabajadas | tiempo de descanso | Netos) / mins
----------------------------------------------------------------------------------------------------
--exec SP_Reporte_Productividad '2025-09-20','2024-09-23',1
CREATE OR ALTER PROCEDURE SP_Reporte_Productividad
  @desde DATE,
  @hasta DATE,
  @idColaborador INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH H AS (
    SELECT r.IDCOLABORADOR,
           SUM(CASE WHEN r.HORAENTRADA IS NOT NULL AND r.HORASALIDA IS NOT NULL
                    THEN DATEDIFF(MINUTE, r.HORAENTRADA, r.HORASALIDA) ELSE 0 END) AS MINUTOS_TRABAJO
    FROM REGISTROSASISTENCIA r
    WHERE r.FECHA BETWEEN @desde AND @hasta
      AND (@idColaborador IS NULL OR r.IDCOLABORADOR = @idColaborador)
    GROUP BY r.IDCOLABORADOR
  ),
  D AS (
    SELECT ta.IDCOLABORADOR,
           SUM(DATEDIFF(MINUTE, d.HORAINICIO, d.HORAFIN)) AS MINUTOS_DESCANSO
    FROM DESCANSOS d
    JOIN TAREASASIGNADAS ta ON ta.IDASIGNACION = d.IDASIGNACION
    WHERE d.HORAINICIO BETWEEN @desde AND DATEADD(DAY, 1, @hasta)
      AND (@idColaborador IS NULL OR ta.IDCOLABORADOR = @idColaborador)
    GROUP BY ta.IDCOLABORADOR
  )
  SELECT COALESCE(H.IDCOLABORADOR, D.IDCOLABORADOR) AS IDCOLABORADOR,
         COALESCE(H.MINUTOS_TRABAJO, 0) AS MINUTOS_TRABAJO,
         COALESCE(D.MINUTOS_DESCANSO, 0) AS MINUTOS_DESCANSO,
         COALESCE(H.MINUTOS_TRABAJO, 0) - COALESCE(D.MINUTOS_DESCANSO, 0) AS MINUTOS_NETOS
  FROM H
  FULL OUTER JOIN D ON H.IDCOLABORADOR = D.IDCOLABORADOR;
END
GO
----------------------------------------------------------------------------------------------------
-- Sección de prueba
----------------------------------------------------------------------------------------------------
/*
-- PRUEBA ÚNICA: cálculo de TRABAJO, DESCANSO y NETOS para 1 colaborador
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  /* 1) Semillas: colaborador, tarea y asignación (para poder registrar descansos) */
  DECLARE @idCol INT, @idTarea INT, @idAsig INT;
  DECLARE @correo NVARCHAR(150)=N'test.product.'+CONVERT(NVARCHAR(36),NEWID())+N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'Product', @correo, N'0', N'USER', 1);
  SET @idCol = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREAS (NOMBRE, DESCRIPCION) VALUES (N'Tarea Prod', N'Desc');
  SET @idTarea = SCOPE_IDENTITY();

  INSERT INTO dbo.TAREASASIGNADAS (IDCOLABORADOR, IDTAREA, FECHAASIGNACION)
  VALUES (@idCol, @idTarea, GETDATE());
  SET @idAsig = SCOPE_IDENTITY();

  /* 2) Rango y datos de asistencia:
        Día 1: 08:00–16:00 = 480 min
        Día 2: 09:00–18:00 = 540 min
        (Total TRABAJO = 1020) */
  DECLARE @d1 DATE = CAST(GETDATE() AS DATE);
  DECLARE @d2 DATE = DATEADD(DAY, 1, @d1);

  INSERT INTO dbo.REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, HORASALIDA)
  VALUES (@idCol, @d1, '08:00', '16:00'),
         (@idCol, @d2, '09:00', '18:00');

  /* 3) Descansos dentro del rango (el SP usa HORAINICIO BETWEEN @desde AND DATEADD(DAY,1,@hasta)):
        D1: 10:00–10:30 = 30 min
        D2: 15:00–15:15 = 15 min
        (Total DESCANSO = 45) */
  INSERT INTO dbo.DESCANSOS (IDASIGNACION, TIPODESCANSO, HORAINICIO, HORAFIN)
  VALUES (@idAsig, N'COFFEE', DATEADD(HOUR,10,CAST(@d1 AS DATETIME)), DATEADD(MINUTE,30,DATEADD(HOUR,10,CAST(@d1 AS DATETIME)))),
         (@idAsig, N'BREAK',  DATEADD(HOUR,15,CAST(@d2 AS DATETIME)), DATEADD(MINUTE,15,DATEADD(HOUR,15,CAST(@d2 AS DATETIME))));

  /* 4) Ejecutar SP y capturar resultado */
  CREATE TABLE #r (IDCOLABORADOR INT, MINUTOS_TRABAJO INT, MINUTOS_DESCANSO INT, MINUTOS_NETOS INT);
  INSERT INTO #r
  EXEC dbo.SP_Reporte_Productividad @desde=@d1, @hasta=@d2, @idColaborador=@idCol;

  /* 5) Verificación: una fila y totales correctos (1020, 45, 975) */
  SELECT
    Caso   = N'Reporte_Productividad (cálculo neto)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #r)=1
                       AND EXISTS(SELECT 1 FROM #r WHERE IDCOLABORADOR=@idCol
                                                     AND MINUTOS_TRABAJO = 1020
                                                     AND MINUTOS_DESCANSO = 45
                                                     AND MINUTOS_NETOS = 975)
                  THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Trabajo=',
                     (SELECT MINUTOS_TRABAJO FROM #r),
                     N' | Descanso=', (SELECT MINUTOS_DESCANSO FROM #r),
                     N' | Netos=', (SELECT MINUTOS_NETOS FROM #r));

  ROLLBACK;  -- no dejar residuos
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK;
  SELECT N'Reporte_Productividad (cálculo neto)' AS Caso,
         N'FALLO' AS Estado,
         ERROR_MESSAGE() AS Detalle;
END CATCH;
*/