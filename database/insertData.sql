-- 1. Insertar tipos de usuarios
INSERT INTO TIPO_USUARIO (DESCRIPCION) VALUES ('Empleado');
INSERT INTO TIPO_USUARIO (DESCRIPCION) VALUES ('Voluntario');


INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile1','Voluntario1');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile2','Voluntario2');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile3','Voluntario3');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile4','Voluntario4');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile5','Voluntario5');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile6','Voluntario6');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile7','Voluntario7');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile8','Voluntario8');
INSERT INTO FOTOS_PERFIL (ARCHIVO, DESCRIPCION) VALUES ('profile9','Voluntario9');



-- 2. Insertar usuarios
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('Juan', 'Pérez', 'Gómez', 'juan.perez@example.com', 'password', 1, 1);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('Ana', 'López', 'Martínez', 'ana.lopez@example.com', 'password', 2, 2);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('Carlos', 'Ramírez', 'Sánchez', 'carlos.ramirez@example.com', 'password', 1, 1);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('María', 'Fernández', 'Rodríguez', 'maria.fernandez@example.com', 'password', 2, 1);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('Lucía', 'Navarro', 'García', 'lucia.navarro@example.com', 'password', 1, 4);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('Pedro', 'González', 'Torres', 'pedro.gonzalez@example.com', 'password', 2, 4);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('Sofía', 'Hernández', 'Lopez', 'sofia.hernandez@example.com', 'password', 1, 3);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('Miguel', 'Cruz', 'Mendoza', 'miguel.cruz@example.com', 'password', 2, 2);
INSERT INTO USUARIOS (NOMBRE, A_PATERNO, A_MATERNO, CORREO, PASS, ID_TIPO_USUARIO, ID_FOTO) VALUES ('AAA', 'BBB', 'CCC', 'aaa.bbb@example.com', 'password', 2, 1);

-- 3. Insertar eventos con las nuevas columnas Lugar y Expositor
INSERT INTO EVENTOS (NOMBRE, DESCRIPCION, NUM_MAX_ASISTENTES, PUNTAJE, FECHA, LUGAR, EXPOSITOR) VALUES ('Conferencia de Tecnología', 'Una conferencia sobre las últimas tendencias en tecnología.', 100, 10, '2024-10-10 09:00:00', 'Auditorio Central', 'Dr. Juan Pérez');

INSERT INTO EVENTOS (NOMBRE, DESCRIPCION, NUM_MAX_ASISTENTES, PUNTAJE, FECHA, LUGAR, EXPOSITOR) VALUES ('Seminario de Desarrollo Personal', 'Un seminario enfocado en el crecimiento personal y profesional.', 50, 8, '2024-10-15 14:00:00', 'Sala de Conferencias A', 'Lic. María González');

INSERT INTO EVENTOS (NOMBRE, DESCRIPCION, NUM_MAX_ASISTENTES, PUNTAJE, FECHA, LUGAR, EXPOSITOR) VALUES ('Taller de Innovación', 'Un taller interactivo sobre innovación y creatividad.', 30, 15, '2024-11-05 11:00:00', 'Laboratorio de Innovación', 'Ing. Carlos Méndez');

INSERT INTO EVENTOS (NOMBRE, DESCRIPCION, NUM_MAX_ASISTENTES, PUNTAJE, FECHA, LUGAR, EXPOSITOR) VALUES ('Conferencia de Marketing', 'Tendencias actuales en marketing digital.', 75, 12, '2024-11-12 10:00:00', 'Auditorio Norte', 'Mtra. Laura Torres');

INSERT INTO EVENTOS (NOMBRE, DESCRIPCION, NUM_MAX_ASISTENTES, PUNTAJE, FECHA, LUGAR, EXPOSITOR) VALUES ('Taller de Trabajo en Equipo', 'Mejorar habilidades de trabajo en equipo.', 40, 10, '2024-12-01 09:30:00', 'Sala de Reuniones B', 'Coach Roberto Díaz');

INSERT INTO EVENTOS (NOMBRE, DESCRIPCION, NUM_MAX_ASISTENTES, PUNTAJE, FECHA, LUGAR, EXPOSITOR) VALUES ('Foro de Innovación Empresarial', 'Discusión sobre innovación en negocios.', 60, 18, '2024-12-15 15:00:00', 'Centro de Convenciones', 'Lic. Ana Rodríguez');
-- 4. Insertar beneficios
INSERT INTO BENEFICIOS (NOMBRE, DESCRIPCION, PUNTOS) VALUES ('Día libre', 'Un día libre extra para descansar.', 20);
INSERT INTO BENEFICIOS (NOMBRE, DESCRIPCION, PUNTOS) VALUES ('Descuento en la cafetería', 'Un 20% de descuento en todas las compras en la cafetería.', 5);
INSERT INTO BENEFICIOS (NOMBRE, DESCRIPCION, PUNTOS) VALUES ('Estacionamiento preferencial', 'Acceso a un espacio de estacionamiento preferencial.', 15);
INSERT INTO BENEFICIOS (NOMBRE, DESCRIPCION, PUNTOS) VALUES ('Vale de gasolina', 'Vale de gasolina por un mes.', 25);
INSERT INTO BENEFICIOS (NOMBRE, DESCRIPCION, PUNTOS) VALUES ('Suscripción a revista', 'Suscripción anual a una revista de negocios.', 10);
INSERT INTO BENEFICIOS (NOMBRE, DESCRIPCION, PUNTOS) VALUES ('Acceso a gimnasio', 'Acceso al gimnasio de la empresa.', 30);

-- 5. Insertar retos
-- 5. Insertar retos con las nuevas columnas
INSERT INTO RETOS (NOMBRE, DESCRIPCION, PUNTAJE, CONTACTO, FECHA_LIMITE) VALUES 
    ('Correr 10km', 'Completar un curso de 10 km.', 10, 'contacto@ejemplo.com', '2024-12-31'),
    ('Participar en 3 eventos', 'Asistir a 3 eventos diferentes organizados por la empresa.', 15, 'contacto@ejemplo.com', '2024-12-31'),
    ('Organizar un evento', 'Organizar un evento de inicio a fin.', 20, 'contacto@ejemplo.com', '2024-12-31'),
    ('Proponer una idea innovadora', 'Proponer y desarrollar una idea que mejore procesos de un evento.', 25, 'contacto@ejemplo.com', '2024-12-31'),
    ('Completar curso de liderazgo', 'Curso en línea sobre habilidades de liderazgo.', 15, 'contacto@ejemplo.com', '2024-12-31'),
    ('Mentorear a un nuevo empleado', 'Ser mentor de un nuevo empleado durante su primer mes.', 20, 'contacto@ejemplo.com', '2024-12-31');
-- 6. Insertar relación usuarios-beneficios
INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES (1, 1); -- Juan obtiene Día libre
INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES (2, 2); -- Ana obtiene Descuento en la cafetería
INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES (3, 3); -- Carlos obtiene Estacionamiento preferencial
INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES (4, 4); -- Lucía obtiene Vale de gasolina
INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES (5, 5); -- Pedro obtiene Suscripción a revista
INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES (6, 6); -- Sofía obtiene Acceso a gimnasio
INSERT INTO USUARIOS_BENEFICIOS (USUARIO, BENEFICIO) VALUES (7, 1); -- Miguel obtiene Día libre

-- 7. Insertar relación usuarios-eventos
INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO) VALUES (1, 1); -- Juan asiste a Conferencia de Tecnología
INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO) VALUES (2, 2); -- Ana asiste a Seminario de Desarrollo Personal
INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO) VALUES (3, 3); -- Carlos asiste a Taller de Innovación
INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO) VALUES (4, 4); -- Lucía asiste a Conferencia de Marketing
INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO) VALUES (5, 5); -- Pedro asiste a Taller de Trabajo en Equipo
INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO) VALUES (6, 6); -- Sofía asiste a Foro de Innovación Empresarial
INSERT INTO USUARIOS_EVENTOS (USUARIO, EVENTO) VALUES (7, 1); -- Miguel asiste a Conferencia de Tecnología

-- 8. Insertar relación usuarios-retos
INSERT INTO USUARIOS_RETOS (ID, ID_RETO) VALUES (1, 1); -- Juan completa curso de 10 km
INSERT INTO USUARIOS_RETOS (ID, ID_RETO) VALUES (2, 2); -- Ana participa en 3 eventos
INSERT INTO USUARIOS_RETOS (ID, ID_RETO) VALUES (3, 3); -- Carlos organiza un evento
INSERT INTO USUARIOS_RETOS (ID, ID_RETO) VALUES (4, 4); -- Lucía propone una idea innovadora
INSERT INTO USUARIOS_RETOS (ID, ID_RETO) VALUES (5, 5); -- Pedro completa curso de liderazgo
INSERT INTO USUARIOS_RETOS (ID, ID_RETO) VALUES (6, 6); -- Sofía mentorea a un nuevo empleado
INSERT INTO USUARIOS_RETOS (ID, ID_RETO) VALUES (7, 2); -- Miguel participa en 3 eventos

-- 9. Insertar a historial de puntos
INSERT INTO HISTORIAL_PUNTOS (USUARIO, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, BENEFICIO) VALUES (1, 50, 0, 1);
INSERT INTO HISTORIAL_PUNTOS (USUARIO, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, RETO) VALUES (1, 50, 1, 1);
INSERT INTO HISTORIAL_PUNTOS (USUARIO, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, EVENTO) VALUES (1, 50, 1, 1);
INSERT INTO HISTORIAL_PUNTOS (USUARIO, PUNTOS_MODIFICADOS, TIPO_MODIFICACION, EVENTO) VALUES (2, 50, 1, 2);

-- 10. Insertar puntos
INSERT INTO PUNTOS_USUARIO (USUARIO, PUNTOS_ACTUALES) VALUES (1, 100);
INSERT INTO PUNTOS_USUARIO (USUARIO, PUNTOS_ACTUALES) VALUES (2, 300);

