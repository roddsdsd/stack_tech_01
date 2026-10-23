-- =============================================================
-- Stack tecnológico 02 · 03_seguridad.sql
-- Login de mínimo privilegio para las aplicaciones.
-- La contraseña llega como variable de sqlcmd: -v APP_PASSWORD=...
-- =============================================================

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'stack_app')
    CREATE LOGIN stack_app WITH PASSWORD = N'$(APP_PASSWORD)', CHECK_POLICY = OFF;
ELSE
    ALTER LOGIN stack_app WITH PASSWORD = N'$(APP_PASSWORD)';
GO

USE stack02;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'stack_app')
    CREATE USER stack_app FOR LOGIN stack_app;
GO

-- Lectura de todas las tablas y vistas
ALTER ROLE db_datareader ADD MEMBER stack_app;

-- Única escritura permitida: el historial de WildFly
GRANT INSERT ON dbo.verificaciones TO stack_app;
GO

PRINT N'Base stack02 lista.';
GO
