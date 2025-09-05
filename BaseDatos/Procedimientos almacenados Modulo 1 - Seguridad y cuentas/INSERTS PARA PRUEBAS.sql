-- =============================
-- INSERTS DE PRUEBA, RECORDAR CAMBIAR LOS ID'S POR LAS PRUEBAS QUE SE HAN IDO HACIENDO
-- =============================

-- 1. COLABORADORES
INSERT INTO COLABORADORES (NOMBRE, APELLIDO, CORREO, TELEFONO, ROL, ESTADO)
VALUES ('Juan', 'Pérez', 'juan.perez@empresa.com', '8888-8888', 'Administrador', 1);

-- 2. USUARIO (ligado al colaborador anterior)
INSERT INTO USUARIO (IDCOLABORADOR, CONTRASEÑA)
VALUES (7, 'Prueba#2025'); -- Recuerda: aplicar hash en la implementación real

-- 3. REGISTROSASISTENCIA (ligado al colaborador)
INSERT INTO REGISTROSASISTENCIA (IDCOLABORADOR, FECHA, HORAENTRADA, HORASALIDA, IPREGISTRO, MACADDRESS)
VALUES (1, GETDATE(), '08:00', '17:00', '192.168.0.10', '00-14-22-01-23-45');

-- 4. TAREAS
INSERT INTO TAREAS (NOMBRE, DESCRIPCION)
VALUES ('Desarrollar módulo de asistencia', 'Implementar el módulo de registro de entradas y salidas en el sistema.');

-- 5. TAREASASIGNADAS (colaborador + tarea)
INSERT INTO TAREASASIGNADAS (IDCOLABORADOR, IDTAREA, FECHAASIGNACION)
VALUES (7, 1, GETDATE());

-- 6. DESCANSOS (ligado a la tarea asignada)
INSERT INTO DESCANSOS (IDASIGNACION, TIPODESCANSO, HORAINICIO, HORAFIN, MOTIVO)
VALUES (3, 'Almuerzo', DATEADD(HOUR, 12, CAST(GETDATE() AS DATETIME)), DATEADD(HOUR, 13, CAST(GETDATE() AS DATETIME)), 'Almuerzo diario');

-- 7. PERMISOS (ligado al colaborador)
INSERT INTO PERMISOS (IDCOLABORADOR, FECHASOLICITUD, FECHAINICIO, FECHAFIN, MOTIVO, ESTADO)
VALUES (7, GETDATE(), DATEADD(DAY, 1, GETDATE()), DATEADD(DAY, 2, GETDATE()), 'Cita médica', 'Pendiente');

-- 8. BITACORA_ERRORES
INSERT INTO BITACORA_ERRORES (MODULO, ERROR)
VALUES ('Módulo de Autenticación', 'Error de credenciales no válidas en prueba unitaria.');
