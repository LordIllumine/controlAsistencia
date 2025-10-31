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

  DECLARE @ROL_COLABORADOR VARCHAR(50);

   --Obtener el rol del colaborador
   SELECT @ROL_COLABORADOR = ROL 
   FROM COLABORADORES 
   WHERE IDCOLABORADOR = @idColaborador;

   IF(@ROL_COLABORADOR = 'Administrador')
   BEGIN
	   SELECT IDCOLABORADOR, 
			  NOMBRE, 
			  APELLIDO, 
			  CORREO, 
			  TELEFONO, 
			  ROL, 
			  ESTADO, 
			  FECHA_CREACION AS [CREACION], 
			  FECHA_ACTUALIZACION AS [ACTUALIZACION]
		 FROM COLABORADORES
		ORDER BY NOMBRE ASC
   END
   ELSE
   BEGIN
	   SELECT IDCOLABORADOR AS [IDENTIFICADOR], 
			  NOMBRE, 
			  APELLIDO, 
			  CORREO, 
			  TELEFONO, 
			  ROL, 
			  ESTADO, 
			  FECHA_CREACION AS [CREACION], 
			  FECHA_ACTUALIZACION AS [ACTUALIZACION]
		 FROM COLABORADORES 
		WHERE IDCOLABORADOR = @idColaborador;
   END
END
GO

----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Tarea_Create / SP_Tarea_Update / SP_Tarea_List
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimientos CRUD de Tareas
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE SP_Tarea_Create
  @nombre		NVARCHAR(200),
  @descripcion	NVARCHAR(MAX) = NULL,
  @fechaInicio	DATETIME,
  @fechaFin		DATETIME,
  @idTarea		INT OUT,
  @mensaje		NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    INSERT INTO TAREAS (NOMBRE, DESCRIPCION, FECHA_INICIO_TAREA, FECHA_FIN_TAREA, FECHA_CREACION, FECHA_ACTUALIZACION, ESTADO) 
			    VALUES (@nombre, @descripcion, @fechaInicio, @fechaFin, GETDATE(), GETDATE(), 'Activa');
    SET @idTarea = SCOPE_IDENTITY();
    SET @mensaje = N'Tarea creada.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al crear tarea.';
    EXEC SP_Bitacora_LogError N'Tarea_Create', ERROR_MESSAGE;
  END CATCH
END
GO

CREATE OR ALTER PROCEDURE SP_Elimianr_Asignaciones
  @idTarea		 INT,
  @idColaborador INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DELETE FROM TAREASASIGNADAS 
	WHERE IDCOLABORADOR = @idColaborador
	  AND IDTAREA = @idTarea
  END TRY
  BEGIN CATCH
    EXEC SP_Bitacora_LogError N'SP_Elimianr_Asignaciones', ERROR_MESSAGE;
  END CATCH
END
GO

CREATE OR ALTER PROCEDURE SP_Tarea_Update
  @idTarea		INT,
  @nombre		NVARCHAR(200) = NULL,
  @descripcion	NVARCHAR(MAX) = NULL,
  @estadoTarea	NVARCHAR(50) = NULL,
  @fechaInicio	DATETIME	  = NULL,
  @fechaFin		DATETIME	  = NULL,
  @mensaje		NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    UPDATE TAREAS
       SET NOMBRE = COALESCE(@nombre, NOMBRE),
           DESCRIPCION = COALESCE(@descripcion, DESCRIPCION),
           FECHA_ACTUALIZACION = GETDATE(),
		   ESTADO = @estadoTarea,
		   FECHA_INICIO_TAREA = @fechaInicio,
		   FECHA_FIN_TAREA = @fechaFin
     WHERE IDTAREA = @idTarea;

    IF @@ROWCOUNT = 0 SET @mensaje = N'No se encontró la tarea.'; ELSE SET @mensaje = N'Tarea actualizada.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al actualizar tarea.';
    EXEC SP_Bitacora_LogError N'Tarea_Update', ERROR_MESSAGE;
  END CATCH
END
GO

----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Asignacion_Create / SP_Asignacion_List
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimientos SP_Asignacion_Create asigna una tarea creada SP_Asignacion_List lista tareas asignadas
----------------------------------------------------------------------------------------------------
ALTER   PROCEDURE [dbo].[SP_Asignacion_Create]
  @idColaborador INT,
  @idTarea       INT,
  --@fechaAsignacion DATETIME,
  @idAsignacion  INT OUT,
  @mensaje       NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
	IF NOT EXISTS(SELECT IDASIGNACION FROM TAREASASIGNADAS WHERE IDCOLABORADOR = @idColaborador AND IDTAREA = @idTarea)
	BEGIN
		INSERT INTO TAREASASIGNADAS (IDCOLABORADOR, IDTAREA, FECHAASIGNACION)
		VALUES (@idColaborador, @idTarea, GETDATE());

		SET @idAsignacion = SCOPE_IDENTITY();
		SET @mensaje = N'Asignación creada.';
	END
    
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al crear la asignación.';
    EXEC SP_Bitacora_LogError N'Asignacion_Create', ERROR_MESSAGE;
  END CATCH
END
GO

----------------------------------------------------------------------------------------------------
ALTER TABLE PERMISOS ADD DESCRIPCION VARCHAR(MAX)
go

CREATE OR ALTER   PROCEDURE [dbo].[SP_Permiso_List]
  @idColaborador INT = NULL,
  @estado        NVARCHAR(50) = NULL,
  @desde         DATETIME = NULL,
  @hasta         DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @ROL_COLABORADOR VARCHAR(50);

   --Obtener el rol del colaborador
   SELECT @ROL_COLABORADOR = ROL 
   FROM COLABORADORES 
   WHERE IDCOLABORADOR = @idColaborador;
   
   IF(@ROL_COLABORADOR = 'Administrador')
   BEGIN
	   SELECT IDPERMISO, IDCOLABORADOR, FECHASOLICITUD, FECHAINICIO,
				 FECHAFIN, MOTIVO, DESCRIPCION, ESTADO, FECHA_CREACION, FECHA_ACTUALIZACION
		 FROM PERMISOS
		WHERE (@estado IS NULL OR ESTADO = @estado)
		  AND (@desde IS NULL OR FECHAINICIO >= @desde)
		  AND (@hasta IS NULL OR FECHAFIN <= @hasta);
   END
   ELSE
   BEGIN
		 SELECT IDPERMISO, IDCOLABORADOR, FECHASOLICITUD, FECHAINICIO,
				 FECHAFIN, MOTIVO, DESCRIPCION, ESTADO, FECHA_CREACION, FECHA_ACTUALIZACION
		FROM PERMISOS
		WHERE (@idColaborador IS NULL OR IDCOLABORADOR = @idColaborador)
		  AND (@estado IS NULL OR ESTADO = @estado)
		  AND (@desde IS NULL OR FECHAINICIO >= @desde)
		  AND (@hasta IS NULL OR FECHAFIN <= @hasta);
   END
  
END
GO

CREATE OR ALTER   PROCEDURE [dbo].[SP_Permiso_ID]
  @idColaborador INT = NULL,
  @idPermiso INT = NULL
AS
BEGIN
  SET NOCOUNT ON;
	   SELECT IDPERMISO, IDCOLABORADOR, FECHASOLICITUD, FECHAINICIO,
				 FECHAFIN, MOTIVO, DESCRIPCION, ESTADO, FECHA_CREACION, FECHA_ACTUALIZACION
		 FROM PERMISOS
		WHERE IDPERMISO = @idPermiso AND IDCOLABORADOR = @idColaborador
  
END
GO

----------------------------------------------------------------------------------------------------
-- Procedimientos almacenados SP_Permiso_Solicitar / SP_Permiso_CambiarEstado / SP_Permiso_List
-- Author: Damian Alvarado Avilés
-- Fecha: 02/09/2025
-- Procedimientos 
----------------------------------------------------------------------------------------------------
ALTER   PROCEDURE [dbo].[SP_Permiso_Solicitar]
  @idColaborador INT,
  @fechaInicio   DATETIME,
  @fechaFin      DATETIME,
  @motivo        NVARCHAR(MAX) = NULL,
  @descripcion	 NVARCHAR(MAX) = NULL,
  @idPermiso     INT OUT,
  @mensaje       NVARCHAR(200) OUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    IF @fechaFin < @fechaInicio
    BEGIN
      SET @mensaje = N'El fin del permiso no puede ser anterior al inicio.';
      RETURN;
    END

    INSERT INTO PERMISOS (IDCOLABORADOR, FECHASOLICITUD, FECHAINICIO, FECHAFIN, MOTIVO, DESCRIPCION, ESTADO)
    VALUES (@idColaborador, GETDATE(), @fechaInicio, @fechaFin, @motivo,@descripcion, N'Pendiente');

    SET @idPermiso = SCOPE_IDENTITY();
    SET @mensaje = N'Permiso solicitado.';
  END TRY
  BEGIN CATCH
    SET @mensaje = N'Error al solicitar permiso.';
    EXEC SP_Bitacora_LogError N'Permiso_Solicitar', ERROR_MESSAGE;
  END CATCH
END
GO