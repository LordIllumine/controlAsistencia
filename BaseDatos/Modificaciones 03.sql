CREATE OR ALTER PROCEDURE SP_Tarea_List_id
  @IDTAREA INT
AS
BEGIN
   SELECT IDTAREA,
          NOMBRE,
          DESCRIPCION,
          ESTADO AS ESTADOTAREA,
          FECHA_INICIO_TAREA,
          FECHA_FIN_TAREA
     FROM TAREAS
    WHERE IDTAREA = @IDTAREA
END;
GO

CREATE OR ALTER PROCEDURE SP_List_Asignaciones
  @IDTAREA INT,
  @ID_COLABORADOR INT 
AS
BEGIN

    DECLARE @ROL_COLABORADOR VARCHAR(50);

    --Obtener el rol del colaborador
    SELECT @ROL_COLABORADOR = ROL 
    FROM COLABORADORES 
    WHERE IDCOLABORADOR = @ID_COLABORADOR;

    SELECT   
        -- ASIGNACIONES
		TA.IDTAREA,
        TA.IDASIGNACION,
        TA.FECHAASIGNACION,
        TA.ESTADO AS ESTADO_ASIGNACION_TAREA,
        -- COLABORADOR
        CO.IDCOLABORADOR,
        CO.NOMBRE AS NOMBRE_COLABORADOR,
        CO.APELLIDO,
        CO.CORREO,
        CO.TELEFONO,
        CO.ROL,
        CO.ESTADO AS ESTADOCOLABORADOR
    FROM TAREAS T
    LEFT JOIN TAREASASIGNADAS TA 
        ON T.IDTAREA = TA.IDTAREA
    LEFT JOIN COLABORADORES CO 
        ON TA.IDCOLABORADOR = CO.IDCOLABORADOR
    WHERE TA.IDTAREA = @IDTAREA
END;
GO

----------------------------------------------------------------------------------------------------
-- Pruebas de SP's
----------------------------------------------------------------------------------------------------
-- EXEC SP_Tarea_List 'Pendiente', '2024-10-11 00:26:24.097','2026-10-11 00:26:24.097', 1016
-- EXEC SP_Tarea_List 'Completada', '2024-10-11 00:26:24.097','2026-10-11 00:26:24.097', 1016
-- EXEC SP_Tarea_List null, '2024-10-11 00:26:24.097','2026-10-11 00:26:24.097', 1016
-- EXEC SP_Tarea_List 'Pendiente', null, null, 1016
-- EXEC SP_Tarea_List 'Completada', null, null, 1016
-- EXEC SP_Tarea_List 'Cancelada', null, null, 1
-- EXEC SP_Tarea_List 'Todos', null, null, 11016
-- GO

CREATE OR ALTER PROCEDURE SP_Tarea_List
  @FILTRO         VARCHAR(100) = NULL,
  @FECHA_INICIO   DATETIME     = NULL,
  @FECHA_FIN      DATETIME     = NULL,
  @ID_COLABORADOR INT 
AS
BEGIN
    SET NOCOUNT ON;

	IF (@FILTRO = 'Todos')
	BEGIN
		SET @FILTRO = NULL
	END

    DECLARE @ROL_COLABORADOR VARCHAR(50);

    --Obtener el rol del colaborador
    SELECT @ROL_COLABORADOR = ROL 
    FROM COLABORADORES 
    WHERE IDCOLABORADOR = @ID_COLABORADOR;

    SELECT distinct
        T.IDTAREA,
        T.NOMBRE,
        T.DESCRIPCION,
        T.ESTADO AS ESTADOTAREA,
        T.FECHA_INICIO_TAREA,
        T.FECHA_FIN_TAREA
    FROM TAREAS T
    LEFT JOIN TAREASASIGNADAS TA 
        ON T.IDTAREA = TA.IDTAREA
    LEFT JOIN COLABORADORES CO 
        ON TA.IDCOLABORADOR = CO.IDCOLABORADOR

    WHERE 
        (
            -- Condición general por rol
            (
                @ROL_COLABORADOR = 'administrador'
                OR (
                    @ROL_COLABORADOR = 'user'
                    AND TA.IDCOLABORADOR = @ID_COLABORADOR
                )
            )
        )
        AND
        (
            -- 1️⃣ Si @FILTRO, @FECHA_INICIO y @FECHA_FIN son NULL → mostrar todas
            (@FILTRO IS NULL AND @FECHA_INICIO IS NULL AND @FECHA_FIN IS NULL)
            OR
            -- 2️⃣ Si @FILTRO es NULL y hay rango de fechas → filtrar por rango
            (@FILTRO IS NULL 
             AND @FECHA_INICIO IS NOT NULL 
             AND @FECHA_FIN IS NOT NULL
             AND (
                    (T.FECHA_INICIO_TAREA BETWEEN @FECHA_INICIO AND @FECHA_FIN)
                 OR (T.FECHA_FIN_TAREA BETWEEN @FECHA_INICIO AND @FECHA_FIN)
                 )
            )
            OR
            -- 3️⃣ Si @FILTRO tiene valor y fechas son NULL → filtrar por estado de la asignación
            (@FILTRO IS NOT NULL 
             AND @FECHA_INICIO IS NULL 
             AND @FECHA_FIN IS NULL 
             AND TA.ESTADO = @FILTRO)
            OR
            -- 4️⃣ Si @FILTRO tiene valor y además hay rango de fechas → combinar ambos
            (@FILTRO IS NOT NULL 
             AND @FECHA_INICIO IS NOT NULL 
             AND @FECHA_FIN IS NOT NULL
             AND TA.ESTADO = @FILTRO
             AND (
                    (T.FECHA_INICIO_TAREA BETWEEN @FECHA_INICIO AND @FECHA_FIN)
                 OR (T.FECHA_FIN_TAREA BETWEEN @FECHA_INICIO AND @FECHA_FIN)
                 )
            )
        );

END;
GO

ALTER   PROCEDURE [dbo].[SP_Colaborador_List]
  @idColaborador NVARCHAR(150) = NULL,
  @texto		 NVARCHAR(150) = NULL,
  @rol			 NVARCHAR(50)  = NULL,
  @estado		 BIT          = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT IDCOLABORADOR AS [IDENTIFICADOR], NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO, FECHA_CREACION AS CREACION, FECHA_ACTUALIZACION AS ACTUALIACION
  FROM COLABORADORES
  WHERE (@idColaborador IS NULL OR IDCOLABORADOR = @idColaborador)
    AND (@texto IS NULL OR (NOMBRE LIKE '%'+@texto+'%' OR APELLIDO LIKE '%'+@texto+'%' OR CORREO LIKE '%'+@texto+'%'))
    AND (@rol IS NULL OR ROL = @rol)
    AND (@estado IS NULL OR ESTADO = @estado);
END
GO