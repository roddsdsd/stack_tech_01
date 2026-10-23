"""Stack tecnológico 02 · API JSON del grafo y de la documentación."""

import os
from collections.abc import Iterator
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.db import conectar
from app.modelos import Grafo, Nodo, Salud, TecnologiaDetalle, Verificacion
from app.repositorio import Repositorio

app = FastAPI(
    title="Stack tecnológico 02 · API",
    version="1.0.0",
    description="Nodos, enlaces y documentación del stack, leídos de SQL Server.",
)

# El sitio (localhost:8080) es otro origen: el navegador exige esta autorización.
ORIGENES = os.getenv("ORIGENES_PERMITIDOS", "http://localhost:8080").split(",")
app.add_middleware(CORSMiddleware, allow_origins=ORIGENES, allow_methods=["GET"], allow_headers=["*"])


def obtener_repositorio() -> Iterator[Repositorio]:
    """Dependencia: abre una conexión por petición y la cierra al terminar."""
    try:
        conexion = conectar()
    except Exception as error:  # pyodbc.Error; sin importar pyodbc aquí
        raise HTTPException(status_code=503, detail=f"SQL Server no disponible: {error}") from error
    try:
        yield Repositorio(conexion)
    finally:
        conexion.close()


Repo = Annotated[Repositorio, Depends(obtener_repositorio)]


@app.get("/salud", response_model=Salud)
def salud():
    return {"servicio": "fastapi", "ok": True}


@app.get("/api/grafo", response_model=Grafo)
def grafo(repo: Repo):
    return {"nodos": repo.nodos(), "enlaces": repo.enlaces()}


@app.get("/api/tecnologias", response_model=list[Nodo])
def tecnologias(repo: Repo):
    return repo.nodos()


@app.get("/api/tecnologias/{clave}", response_model=TecnologiaDetalle)
def tecnologia(clave: str, repo: Repo):
    nodo = repo.tecnologia(clave)
    if nodo is None:
        raise HTTPException(status_code=404, detail=f"No existe la tecnología '{clave}'")
    return {**nodo, "secciones": repo.secciones(nodo["id"])}


@app.get("/api/verificaciones", response_model=list[Verificacion])
def verificaciones(repo: Repo):
    """Historial que escribe WildFly en la misma base de datos."""
    return repo.verificaciones()
