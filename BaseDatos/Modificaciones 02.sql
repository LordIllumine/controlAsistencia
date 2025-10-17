ALTER TABLE TAREAS ADD FECHA_INICIO_TAREA DATETIME 
ALTER TABLE TAREAS ADD FECHA_FIN_TAREA DATETIME 
GO

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--EXEC SP_Tarea_List 'Pendiente', '2024-10-11 00:26:24.097','2026-10-11 00:26:24.097', 1016
--EXEC SP_Tarea_List 'Completada', '2024-10-11 00:26:24.097','2026-10-11 00:26:24.097', 1016
--EXEC SP_Tarea_List null, '2024-10-11 00:26:24.097','2026-10-11 00:26:24.097', 1016
--EXEC SP_Tarea_List 'Pendiente', null, null, 1016
--EXEC SP_Tarea_List 'Completada', null, null, 1016
--GO
CREATE OR ALTER PROCEDURE SP_Tarea_List
  @FILTRO         VARCHAR(100) = NULL,
  @FECHA_INICIO   DATETIME     = NULL,
  @FECHA_FIN      DATETIME     = NULL,
  @ID_COLABORADOR INT 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ROL_COLABORADOR VARCHAR(50);

    --Obtener el rol del colaborador
    SELECT @ROL_COLABORADOR = ROL 
    FROM COLABORADORES 
    WHERE IDCOLABORADOR = @ID_COLABORADOR;

    SELECT 
        T.IDTAREA,
        T.NOMBRE,
        T.DESCRIPCION,
        T.ESTADO AS ESTADOTAREA,
        T.FECHA_INICIO_TAREA,
        T.FECHA_FIN_TAREA,

        -- ASIGNACIONES
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

    WHERE 
        (
            -- 🧩 Condición general por rol
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
