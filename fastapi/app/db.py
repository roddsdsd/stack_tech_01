"""Conexión a SQL Server con pyodbc y el ODBC Driver 18."""

import os


def cadena_conexion() -> str:
    """Arma la cadena ODBC con variables de entorno (las define docker-compose.yml)."""
    clave = os.getenv("DB_PASSWORD", "").replace("}", "}}")
    return ";".join(
        [
            "DRIVER={ODBC Driver 18 for SQL Server}",
            f"SERVER={os.getenv('DB_HOST', 'localhost')},{os.getenv('DB_PORT', '1433')}",
            f"DATABASE={os.getenv('DB_NAME', 'stack02')}",
            f"UID={os.getenv('DB_USER', 'stack_app')}",
            f"PWD={{{clave}}}",  # entre llaves por si la contraseña contiene ;
            "Encrypt=yes",
            "TrustServerCertificate=yes",  # certificado autofirmado del contenedor: solo desarrollo
        ]
    )


def conectar():
    # Importación tardía: las pruebas no necesitan el driver ODBC instalado.
    import pyodbc

    return pyodbc.connect(cadena_conexion(), timeout=5)
