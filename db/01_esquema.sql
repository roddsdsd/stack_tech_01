-- =============================================================
-- Stack tecnológico 02 · 01_esquema.sql
-- Crea la base de datos, las tablas y la vista. Es idempotente:
-- se puede ejecutar varias veces (borra y recrea el contenido,
-- pero conserva el historial de verificaciones).
-- =============================================================

IF DB_ID(N'stack02') IS NULL
    CREATE DATABASE stack02;
GO

USE stack02;
GO

IF OBJECT_ID(N'dbo.v_enlaces', N'V') IS NOT NULL DROP VIEW dbo.v_enlaces;
IF OBJECT_ID(N'dbo.archivos', N'U') IS NOT NULL DROP TABLE dbo.archivos;
IF OBJECT_ID(N'dbo.secciones', N'U') IS NOT NULL DROP TABLE dbo.secciones;
IF OBJECT_ID(N'dbo.enlaces', N'U') IS NOT NULL DROP TABLE dbo.enlaces;
IF OBJECT_ID(N'dbo.tecnologias', N'U') IS NOT NULL DROP TABLE dbo.tecnologias;
GO

-- Un nodo del grafo por fila
CREATE TABLE dbo.tecnologias (
    id          INT IDENTITY(1, 1) PRIMARY KEY,
    clave       NVARCHAR(30)  NOT NULL UNIQUE,   -- identificador en URLs y JSON
    nombre      NVARCHAR(60)  NOT NULL,
    rol         NVARCHAR(40)  NOT NULL,          -- texto corto bajo el nombre del nodo
    capa        NVARCHAR(20)  NOT NULL,          -- cliente, presentacion, api, servicio, datos, herramienta
    descripcion NVARCHAR(MAX) NOT NULL,
    version     NVARCHAR(80)  NULL,
    puerto      NVARCHAR(80)  NULL,
    x           INT NOT NULL,                    -- posición en el lienzo SVG (1000 x 600)
    y           INT NOT NULL,
    orden       INT NOT NULL UNIQUE              -- orden de construcción del proyecto
);

-- Aristas dirigidas: qué viaja de un nodo a otro y cómo se transforma
CREATE TABLE dbo.enlaces (
    id             INT IDENTITY(1, 1) PRIMARY KEY,
    origen_id      INT NOT NULL REFERENCES dbo.tecnologias (id),
    destino_id     INT NOT NULL REFERENCES dbo.tecnologias (id),
    tipo           NVARCHAR(20)  NOT NULL CHECK (tipo IN (N'ejecucion', N'construccion')),
    etiqueta       NVARCHAR(40)  NOT NULL,
    protocolo      NVARCHAR(200) NOT NULL,
    dato_ida       NVARCHAR(MAX) NOT NULL,
    dato_vuelta    NVARCHAR(MAX) NOT NULL,
    transformacion NVARCHAR(MAX) NOT NULL,
    curva          INT NOT NULL DEFAULT 0        -- curvatura de la línea en el grafo
);

-- Bloques de documentación de cada tecnología
CREATE TABLE dbo.secciones (
    id            INT IDENTITY(1, 1) PRIMARY KEY,
    tecnologia_id INT NOT NULL REFERENCES dbo.tecnologias (id) ON DELETE CASCADE,
    orden         INT NOT NULL,
    titulo        NVARCHAR(120) NULL,            -- NULL: continúa la sección anterior
    tipo          NVARCHAR(10)  NOT NULL CHECK (tipo IN (N'texto', N'comando', N'codigo', N'nota')),
    lenguaje      NVARCHAR(20)  NULL,
    contenido     NVARCHAR(MAX) NOT NULL
);

-- Archivos del repositorio que se muestran en cada página
CREATE TABLE dbo.archivos (
    id            INT IDENTITY(1, 1) PRIMARY KEY,
    tecnologia_id INT NOT NULL REFERENCES dbo.tecnologias (id) ON DELETE CASCADE,
    orden         INT NOT NULL,
    ruta          NVARCHAR(260) NOT NULL,        -- relativa a la raíz del repositorio
    descripcion   NVARCHAR(400) NOT NULL
);

-- Historial que escribe WildFly; se conserva entre reinicializaciones
IF OBJECT_ID(N'dbo.verificaciones', N'U') IS NULL
    CREATE TABLE dbo.verificaciones (
        id           BIGINT IDENTITY(1, 1) PRIMARY KEY,
        servicio     NVARCHAR(30)  NOT NULL,
        ok           BIT           NOT NULL,
        milisegundos INT           NOT NULL,
        detalle      NVARCHAR(400) NULL,
        fecha        DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME()
    );
GO

-- La vista evita repetir el mismo JOIN en PHP, Python y Java
CREATE VIEW dbo.v_enlaces AS
SELECT e.id,
       e.tipo,
       e.origen_id,
       o.clave  AS origen_clave,
       o.nombre AS origen_nombre,
       e.destino_id,
       d.clave  AS destino_clave,
       d.nombre AS destino_nombre,
       e.etiqueta,
       e.protocolo,
       e.dato_ida,
       e.dato_vuelta,
       e.transformacion,
       e.curva
FROM dbo.enlaces e
JOIN dbo.tecnologias o ON o.id = e.origen_id
JOIN dbo.tecnologias d ON d.id = e.destino_id;
GO
