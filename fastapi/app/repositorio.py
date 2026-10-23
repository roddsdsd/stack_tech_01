"""Todo el SQL de la API. Devuelve diccionarios; la validación la hacen los modelos."""

SQL_NODOS = """
    SELECT id, clave, nombre, rol, capa, descripcion, version, puerto, x, y, orden
    FROM tecnologias
    ORDER BY orden
"""

SQL_NODO = """
    SELECT id, clave, nombre, rol, capa, descripcion, version, puerto, x, y, orden
    FROM tecnologias
    WHERE clave = ?
"""

SQL_ENLACES = """
    SELECT id, tipo, origen_clave AS origen, destino_clave AS destino, etiqueta,
           protocolo, dato_ida, dato_vuelta, transformacion, curva
    FROM v_enlaces
    ORDER BY id
"""

SQL_SECCIONES = """
    SELECT orden, titulo, tipo, lenguaje, contenido
    FROM secciones
    WHERE tecnologia_id = ?
    ORDER BY orden
"""

SQL_VERIFICACIONES = """
    SELECT TOP (?) servicio, ok, milisegundos, detalle, fecha
    FROM verificaciones
    ORDER BY id DESC
"""


class Repositorio:
    def __init__(self, conexion):
        self.conexion = conexion

    def _consultar(self, sql: str, *parametros) -> list[dict]:
        cursor = self.conexion.cursor()
        cursor.execute(sql, *parametros)  # los ? se envían aparte: sin inyección SQL
        columnas = [columna[0] for columna in cursor.description]
        return [dict(zip(columnas, fila)) for fila in cursor.fetchall()]

    def nodos(self) -> list[dict]:
        return self._consultar(SQL_NODOS)

    def enlaces(self) -> list[dict]:
        return self._consultar(SQL_ENLACES)

    def tecnologia(self, clave: str) -> dict | None:
        filas = self._consultar(SQL_NODO, clave)
        return filas[0] if filas else None

    def secciones(self, tecnologia_id: int) -> list[dict]:
        return self._consultar(SQL_SECCIONES, tecnologia_id)

    def verificaciones(self, limite: int = 20) -> list[dict]:
        return self._consultar(SQL_VERIFICACIONES, limite)
