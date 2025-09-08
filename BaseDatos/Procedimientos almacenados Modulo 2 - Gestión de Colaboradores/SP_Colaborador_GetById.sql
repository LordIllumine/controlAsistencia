----------------------------------------------------------------------------------------------------
-- Procedimiento almacenado SP_Colaborador_GetById
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimiento lista los colaboradores con un ID y varios filtros opcionales
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Colaborador_GetById
  @idColaborador INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT * FROM COLABORADORES WHERE IDCOLABORADOR = @idColaborador;
END
GO

CREATE OR ALTER PROCEDURE SP_Colaborador_List
  @texto NVARCHAR(150) = NULL,
  @rol   NVARCHAR(50)  = NULL,
  @estado BIT          = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT *
  FROM COLABORADORES
  WHERE (@texto IS NULL OR (NOMBRE LIKE '%'+@texto+'%' OR APELLIDO LIKE '%'+@texto+'%' OR CORREO LIKE '%'+@texto+'%'))
    AND (@rol IS NULL OR ROL = @rol)
    AND (@estado IS NULL OR ESTADO = @estado);
END
GO
----------------------------------------------------------------------------------------------------
--Sección de pruebas
----------------------------------------------------------------------------------------------------
/*
---
--- 1
---

-- GETBYID - ÉXITO
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @id INT, @correo NVARCHAR(150) = N'test.getbyid.ok.' + CONVERT(NVARCHAR(36), NEWID()) + N'@example.com';

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Test', N'GetById', @correo, N'00000000', N'USER', 1);
  SET @id = SCOPE_IDENTITY();

  SELECT TOP 0 * INTO #t FROM dbo.COLABORADORES;
  INSERT INTO #t EXEC dbo.SP_Colaborador_GetById @idColaborador=@id;

  SELECT
    Caso   = N'GetById (éxito)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=1
                       AND EXISTS(SELECT 1 FROM #t WHERE IDCOLABORADOR=@id AND CORREO=@correo)
                  THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Filas devueltas=', (SELECT COUNT(*) FROM #t), N' | ID=', @id, N' | ', @correo);

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'GetById (éxito)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
---
-- 2
---
-- GETBYID - ID INEXISTENTE
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;

  SELECT TOP 0 * INTO #t FROM dbo.COLABORADORES;
  INSERT INTO #t EXEC dbo.SP_Colaborador_GetById @idColaborador = -1;

  SELECT
    Caso   = N'GetById (ID inexistente)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=0 THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Filas devueltas=', (SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'GetById (ID inexistente)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
---
--3
---
-- LIST - FILTRO TEXTO
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @pref NVARCHAR(80) = N'test.list.txt.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
  VALUES (N'Ana',  N'Texto', @pref + N'.1@example.com', N'1', N'USER', 1),
         (N'Bruno',N'Texto', @pref + N'.2@example.com', N'2', N'ADMIN',1),
         (N'Carla',N'Texto', @pref + N'.3@example.com', N'3', N'USER', 0);

  SELECT TOP 0 * INTO #t FROM dbo.COLABORADORES;
  INSERT INTO #t EXEC dbo.SP_Colaborador_List @texto=@pref;  -- buscará en CORREO (y también en NOMBRE/APELLIDO)

  SELECT
    Caso   = N'List (texto)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=3 THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Filas devueltas=', (SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'List (texto)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;

---
--4
---
-- LIST - FILTRO ROL
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @pref NVARCHAR(80) = N'test.list.rol.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'Uno',N'Rol', @pref+N'.a@example.com', N'1', N'ADMIN',1),
         (N'Dos',N'Rol', @pref+N'.b@example.com', N'2', N'ADMIN',0),
         (N'Tres',N'Rol',@pref+N'.c@example.com', N'3', N'USER', 1);

  SELECT TOP 0 * INTO #t FROM dbo.COLABORADORES;
  INSERT INTO #t EXEC dbo.SP_Colaborador_List @texto=@pref, @rol=N'ADMIN';

  SELECT
    Caso   = N'List (rol=ADMIN)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=2 AND NOT EXISTS(SELECT 1 FROM #t WHERE ROL<>N'ADMIN')
                  THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Filas devueltas=', (SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'List (rol=ADMIN)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
---
--5
---
-- LIST - FILTRO ESTADO
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @pref NVARCHAR(80) = N'test.list.estado.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'A',N'E', @pref+N'.x@example.com', N'1', N'USER', 0),
         (N'B',N'E', @pref+N'.y@example.com', N'2', N'USER', 1),
         (N'C',N'E', @pref+N'.z@example.com', N'3', N'ADMIN',0);

  SELECT TOP 0 * INTO #t FROM dbo.COLABORADORES;
  INSERT INTO #t EXEC dbo.SP_Colaborador_List @texto=@pref, @estado=0;

  SELECT
    Caso   = N'List (estado=0)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=2 AND NOT EXISTS(SELECT 1 FROM #t WHERE ESTADO<>0)
                  THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Filas devueltas=', (SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'List (estado=0)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
---
--6
---
-- LIST - COMBINADO (texto + rol + estado)
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
  BEGIN TRAN;
  DECLARE @pref NVARCHAR(80) = N'test.list.combo.' + CONVERT(NVARCHAR(36), NEWID());

  INSERT INTO dbo.COLABORADORES (NOMBRE,APELLIDO,CORREO,TELEFONO,ROL,ESTADO)
  VALUES (N'AA',N'C', @pref+N'.1@example.com', N'1', N'USER', 1),  -- debería coincidir
         (N'BB',N'C', @pref+N'.2@example.com', N'2', N'USER', 0),
         (N'CC',N'C', @pref+N'.3@example.com', N'3', N'ADMIN',1);

  SELECT TOP 0 * INTO #t FROM dbo.COLABORADORES;
  INSERT INTO #t EXEC dbo.SP_Colaborador_List @texto=@pref, @rol=N'USER', @estado=1;

  SELECT
    Caso   = N'List (combo: texto+rol=USER+estado=1)',
    Estado = CASE WHEN (SELECT COUNT(*) FROM #t)=1
                       AND EXISTS(SELECT 1 FROM #t WHERE ROL=N'USER' AND ESTADO=1) THEN N'OK' ELSE N'FALLO' END,
    Detalle = CONCAT(N'Filas devueltas=', (SELECT COUNT(*) FROM #t));

  ROLLBACK;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  SELECT N'List (combo)' AS Caso, N'FALLO' AS Estado, ERROR_MESSAGE() AS Detalle;
END CATCH;
*/