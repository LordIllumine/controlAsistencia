-------------------------------------------------
-- Procedimiento almacenado SP_Bitacora_LogError
-- Author: Damian Alvarado Avil�s
-- Fecha: 02/09/2025
-- Procedimiento que almacena en tabla BITACORA_ERRORES los errores registrados en sistema
-------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Bitacora_LogError
  @modulo  NVARCHAR(250),
  @error   NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO BITACORA_ERRORES (MODULO, ERROR) VALUES (@modulo, @error);
END
GO

/*
-- Secci�n de pruebas
/* =========================================================
   PRUEBA 1: llamada directa al SP con un marcador �nico
   ========================================================= */
DECLARE @m NVARCHAR(250) = N'PRUEBA_UNITARIA';
DECLARE @marker CHAR(36) = CONVERT(CHAR(36), NEWID());
DECLARE @e NVARCHAR(MAX) = N'Error simulado para prueba | marker=' + @marker;

EXEC dbo.SP_Bitacora_LogError @modulo = @m, @error = @e;

IF EXISTS (
    SELECT 1
    FROM dbo.BITACORA_ERRORES
    WHERE MODULO = @m AND ERROR LIKE '%' + @marker + '%'
)
    PRINT 'OK: se registr� el error de prueba (' + @marker + ').';
ELSE
    PRINT 'FALLO: no se encontr� el registro de prueba (' + @marker + ').';

-- Vista r�pida de lo insertado para esta prueba
SELECT TOP (5) *
FROM dbo.BITACORA_ERRORES
WHERE MODULO = @m;


/* =========================================================
   PRUEBA 2: uso t�pico dentro de TRY...CATCH
   (se provoca un error y se registra en la bit�cora)
   ========================================================= */
BEGIN TRY
    SELECT 1/0;  -- fuerza divisi�n entre cero
END TRY
BEGIN CATCH
    DECLARE @mod2 NVARCHAR(250) = N'PRUEBA_TRY_CATCH';
    DECLARE @marker2 CHAR(36)   = CONVERT(CHAR(36), NEWID());
    DECLARE @err NVARCHAR(MAX)  = ERROR_MESSAGE() + N' | marker=' + @marker2;

    EXEC dbo.SP_Bitacora_LogError @modulo = @mod2, @error = @err;

    IF EXISTS (
        SELECT 1
        FROM dbo.BITACORA_ERRORES
        WHERE MODULO = @mod2 AND ERROR LIKE '%' + @marker2 + '%'
    )
        PRINT 'OK: se registr� el error desde TRY...CATCH (' + @marker2 + ').';
    ELSE
        PRINT 'FALLO: no se registr� el error desde TRY...CATCH (' + @marker2 + ').';
END CATCH;

-- Vista r�pida de lo insertado para ambas pruebas
SELECT TOP (10) *
FROM dbo.BITACORA_ERRORES
WHERE MODULO IN (N'PRUEBA_UNITARIA', N'PRUEBA_TRY_CATCH');

-- LIMPIEZA OPCIONAL (descomenta si no quieres dejar datos de prueba)
-- DELETE FROM dbo.BITACORA_ERRORES
-- WHERE MODULO IN (N'PRUEBA_UNITARIA', N'PRUEBA_TRY_CATCH');
*/