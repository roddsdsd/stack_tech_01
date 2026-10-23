"""Modelos Pydantic: definen y validan la forma exacta del JSON de cada respuesta."""

from datetime import datetime

from pydantic import BaseModel


class Salud(BaseModel):
    servicio: str
    ok: bool


class Nodo(BaseModel):
    id: int
    clave: str
    nombre: str
    rol: str
    capa: str
    descripcion: str
    version: str | None
    puerto: str | None
    x: int
    y: int
    orden: int


class Enlace(BaseModel):
    id: int
    tipo: str
    origen: str
    destino: str
    etiqueta: str
    protocolo: str
    dato_ida: str
    dato_vuelta: str
    transformacion: str
    curva: int


class Grafo(BaseModel):
    nodos: list[Nodo]
    enlaces: list[Enlace]


class Seccion(BaseModel):
    orden: int
    titulo: str | None
    tipo: str
    lenguaje: str | None
    contenido: str


class TecnologiaDetalle(Nodo):
    secciones: list[Seccion]


class Verificacion(BaseModel):
    servicio: str
    ok: bool
    milisegundos: int
    detalle: str | None
    fecha: datetime
