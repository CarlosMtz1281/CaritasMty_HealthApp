-- 1. Catalogo: (Empleado/Voluntario)
CREATE TABLE TIPO_USUARIO (
    ID_TIPO_USUARIO NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    DESCRIPCION VARCHAR(MAX)
);

CREATE TABLE FOTOS_PERFIL (
    ID_FOTO NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    ARCHIVO VARCHAR(255),
    DESCRIPCION VARCHAR(255)
);

-- 2. Usuarios del sistema
CREATE TABLE USUARIOS (
    ID_USUARIO NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    NOMBRE VARCHAR(100),
    A_PATERNO VARCHAR(100),
    A_MATERNO VARCHAR(100),
    CORREO VARCHAR(150) UNIQUE,
    PASS VARCHAR(255),
    ID_TIPO_USUARIO NUMERIC(18, 0),
    ID_FOTO NUMERIC(18, 0),
    FOREIGN KEY (ID_TIPO_USUARIO) REFERENCES TIPO_USUARIO(ID_TIPO_USUARIO),
    FOREIGN KEY (ID_FOTO) REFERENCES FOTOS_PERFIL(ID_FOTO)
);


-- 3. Eventos disponibles (conferencias, etc)
CREATE TABLE EVENTOS (
    ID_EVENTO NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    NOMBRE VARCHAR(200),
    DESCRIPCION VARCHAR(MAX),
    NUM_MAX_ASISTENTES NUMERIC(18, 0),
    PUNTAJE NUMERIC(18, 0),
    FECHA DATETIME,
    LUGAR VARCHAR(200),        
    EXPOSITOR VARCHAR(150)    
);

-- 4. Beneficios disponibles para alcanzar
CREATE TABLE BENEFICIOS (
    ID_BENEFICIO NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    NOMBRE VARCHAR(200),
    DESCRIPCION VARCHAR(MAX),
    PUNTOS NUMERIC(18, 0)
);

-- 5. Catalogo: Retos disponibles
CREATE TABLE RETOS (
    ID_RETO NUMERIC(18, 0) PRIMARY KEY IDENTITY,  -- ID autoincrementable para el reto
    NOMBRE VARCHAR(MAX),                          -- Nombre del reto
    DESCRIPCION VARCHAR(MAX),                     -- Descripción del reto
    PUNTAJE NUMERIC(18, 0),                       -- Puntuación asociada al reto
    CONTACTO VARCHAR(MAX),                        -- Información de contacto (correo o teléfono)
    FECHA_LIMITE DATE                             -- Fecha límite para completar el reto
);

-- 6. Relacion usuarios y sus beneficios obtenidos
CREATE TABLE USUARIOS_BENEFICIOS (
    ID NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    USUARIO NUMERIC(18, 0),
    BENEFICIO NUMERIC(18, 0),
    FOREIGN KEY (USUARIO) REFERENCES USUARIOS(ID_USUARIO),
    FOREIGN KEY (BENEFICIO) REFERENCES BENEFICIOS(ID_BENEFICIO)
);

-- 7. Relacion usuarios y asistencia a eventos
CREATE TABLE USUARIOS_EVENTOS (
    ID NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    USUARIO NUMERIC(18, 0),
    EVENTO NUMERIC(18, 0),
    FOREIGN KEY (USUARIO) REFERENCES USUARIOS(ID_USUARIO),
    FOREIGN KEY (EVENTO) REFERENCES EVENTOS(ID_EVENTO)
);

-- 8. Relacion usuarios y retos obtenidos
CREATE TABLE USUARIOS_RETOS (
    ID NUMERIC(18, 0),
    ID_RETO NUMERIC(18, 0),
    FOREIGN KEY (ID) REFERENCES USUARIOS(ID_USUARIO),
    FOREIGN KEY (ID_RETO) REFERENCES RETOS(ID_RETO),
    PRIMARY KEY (ID, ID_RETO)
);

-- 9. Relacion usuarios a sus puntos
CREATE TABLE PUNTOS_USUARIO (
    ID NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    USUARIO NUMERIC(18, 0),
    PUNTOS_ACTUALES NUMERIC(18, 0) DEFAULT 0,
    FOREIGN KEY (USUARIO) REFERENCES USUARIOS(ID_USUARIO)
);

-- 10. Transacciones de puntos
CREATE TABLE HISTORIAL_PUNTOS (
    ID NUMERIC(18, 0) PRIMARY KEY IDENTITY,
    USUARIO NUMERIC(18, 0),
    FECHA DATETIME DEFAULT GETDATE(),
    PUNTOS_MODIFICADOS NUMERIC(18, 0),
    TIPO_MODIFICACION BIT, -- TRUE = Añadido, FALSE = Restado
    BENEFICIO NUMERIC(18, 0) NULL,
    EVENTO NUMERIC(18, 0) NULL,
    RETO NUMERIC(18, 0) NULL,
    FOREIGN KEY (USUARIO) REFERENCES USUARIOS(ID_USUARIO),
    FOREIGN KEY (BENEFICIO) REFERENCES BENEFICIOS(ID_BENEFICIO),
    FOREIGN KEY (EVENTO) REFERENCES EVENTOS(ID_EVENTO),
    FOREIGN KEY (RETO) REFERENCES RETOS(ID_RETO),
);

