"""Pruebas de la API con un repositorio falso: no necesitan SQL Server."""

from datetime import datetime

import pytest
from fastapi.testclient import TestClient

from app.main import app, obtener_repositorio

NODO = {
    "id": 1, "clave": "sqlserver", "nombre": "SQL Server", "rol": "Base de datos", "capa": "datos",
    "descripcion": "Guarda el contenido.", "version": "2022", "puerto": "1433", "x": 780, "y": 360, "orden": 3,
}
NODO_API = {**NODO, "id": 2, "clave": "fastapi", "nombre": "FastAPI", "rol": "API JSON", "capa": "api", "orden": 4}
ENLACE = {
    "id": 4, "tipo": "ejecucion", "origen": "fastapi", "destino": "sqlserver", "etiqueta": "pyodbc · TDS",
    "protocolo": "TDS", "dato_ida": "SELECT", "dato_vuelta": "filas", "transformacion": "fila → dict", "curva": 0,
}


class RepositorioFalso:
    def nodos(self):
        return [NODO, NODO_API]

    def enlaces(self):
        return [ENLACE]

    def tecnologia(self, clave):
        return next((n for n in self.nodos() if n["clave"] == clave), None)

    def secciones(self, tecnologia_id):
        return [{"orden": 1, "titulo": "Qué es", "tipo": "texto", "lenguaje": None, "contenido": "Texto."}]

    def verificaciones(self, limite=20):
        return [{"servicio": "sqlserver", "ok": True, "milisegundos": 3, "detalle": None, "fecha": datetime(2026, 1, 1)}]


@pytest.fixture
def cliente():
    app.dependency_overrides[obtener_repositorio] = RepositorioFalso
    yield TestClient(app)
    app.dependency_overrides.clear()


def test_salud(cliente):
    assert cliente.get("/salud").json() == {"servicio": "fastapi", "ok": True}


def test_grafo_contiene_nodos_y_enlaces(cliente):
    datos = cliente.get("/api/grafo").json()
    assert [n["clave"] for n in datos["nodos"]] == ["sqlserver", "fastapi"]
    assert datos["enlaces"][0]["origen"] == "fastapi"


def test_tecnologia_con_secciones(cliente):
    respuesta = cliente.get("/api/tecnologias/sqlserver")
    assert respuesta.status_code == 200
    assert respuesta.json()["secciones"][0]["titulo"] == "Qué es"


def test_tecnologia_inexistente_da_404(cliente):
    assert cliente.get("/api/tecnologias/cobol").status_code == 404


def test_verificaciones(cliente):
    assert cliente.get("/api/verificaciones").json()[0]["servicio"] == "sqlserver"


def test_cors_autoriza_al_sitio(cliente):
    respuesta = cliente.get("/api/grafo", headers={"Origin": "http://localhost:8080"})
    assert respuesta.headers["access-control-allow-origin"] == "http://localhost:8080"


def test_cors_no_autoriza_otros_origenes(cliente):
    respuesta = cliente.get("/api/grafo", headers={"Origin": "http://ejemplo.com"})
    assert "access-control-allow-origin" not in respuesta.headers
