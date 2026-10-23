// Grafo principal. Datos de FastAPI y estado de WildFly, ambos con fetch (sin librerías).

const config = document.body.dataset; // data-api, data-monitor, data-base (plantilla.php)
const SVG_NS = "http://www.w3.org/2000/svg";
const ANCHO = 150;
const ALTO = 56;

const svg = document.getElementById("grafo");
const detalle = document.getElementById("detalle");
const estados = new Map(); // clave del servicio → verificación de WildFly
let nodosPorClave = new Map();
let enlaces = [];

// Envuelve fetch: fetch no falla con 404/500, así que lo convertimos en error.
async function obtenerJSON(url) {
  const respuesta = await fetch(url, {
    headers: { Accept: "application/json" },
    signal: AbortSignal.timeout(8000),
  });
  if (!respuesta.ok) {
    throw new Error(`HTTP ${respuesta.status} en ${url}`);
  }
  return respuesta.json();
}

function crear(tipo, atributos = {}, padre = null) {
  const elemento = document.createElementNS(SVG_NS, tipo);
  for (const [nombre, valor] of Object.entries(atributos)) {
    elemento.setAttribute(nombre, valor);
  }
  if (padre) padre.appendChild(elemento);
  return elemento;
}

function escapar(texto) {
  return String(texto ?? "").replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);
}

// Punto del borde del rectángulo del nodo en dirección a (px, py).
function borde(nodo, px, py) {
  const dx = px - nodo.x;
  const dy = py - nodo.y;
  if (dx === 0 && dy === 0) return { x: nodo.x, y: nodo.y };
  const escala = 1 / Math.max(Math.abs(dx) / (ANCHO / 2 + 4), Math.abs(dy) / (ALTO / 2 + 4));
  return { x: nodo.x + dx * escala, y: nodo.y + dy * escala };
}

// Curva cuadrática de a hacia b; `curva` desplaza el punto de control en perpendicular.
function geometria(a, b, curva) {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const largo = Math.hypot(dx, dy) || 1;
  const control = {
    x: (a.x + b.x) / 2 - (dy / largo) * curva,
    y: (a.y + b.y) / 2 + (dx / largo) * curva,
  };
  const inicio = borde(a, control.x, control.y);
  const fin = borde(b, control.x, control.y);
  const medio = { // punto de la curva en t = 0.5
    x: 0.25 * inicio.x + 0.5 * control.x + 0.25 * fin.x,
    y: 0.25 * inicio.y + 0.5 * control.y + 0.25 * fin.y,
  };
  const r = (n) => n.toFixed(1);
  return {
    d: `M${r(inicio.x)},${r(inicio.y)} Q${r(control.x)},${r(control.y)} ${r(fin.x)},${r(fin.y)}`,
    medio,
  };
}

// Clic y teclado (Enter / espacio) para nodos y enlaces.
function activable(elemento, accion) {
  elemento.setAttribute("tabindex", "0");
  elemento.addEventListener("click", accion);
  elemento.addEventListener("keydown", (evento) => {
    if (evento.key === "Enter" || evento.key === " ") {
      evento.preventDefault();
      accion();
    }
  });
}

function marcarActivo(...elementos) {
  svg.querySelectorAll(".activo").forEach((e) => e.classList.remove("activo"));
  elementos.forEach((e) => e.classList.add("activo"));
}

function dibujar(grafo) {
  svg.replaceChildren();
  nodosPorClave = new Map(grafo.nodos.map((n) => [n.clave, n]));
  enlaces = grafo.enlaces;

  const defs = crear("defs", {}, svg);
  const marcador = crear("marker", {
    id: "flecha", viewBox: "0 0 10 10", refX: "9", refY: "5",
    markerWidth: "7", markerHeight: "7", orient: "auto-start-reverse",
  }, defs);
  crear("path", { d: "M0,0 L10,5 L0,10 z", class: "flecha" }, marcador);

  const capaEnlaces = crear("g", {}, svg);
  const capaEtiquetas = crear("g", {}, svg);
  const capaNodos = crear("g", {}, svg);

  for (const enlace of enlaces) {
    const origen = nodosPorClave.get(enlace.origen);
    const destino = nodosPorClave.get(enlace.destino);
    const { d, medio } = geometria(origen, destino, enlace.curva);

    const grupo = crear("g", { class: `enlace ${enlace.tipo}`, "data-id": enlace.id }, capaEnlaces);
    crear("path", { d, class: "zona" }, grupo);
    crear("path", { d, class: "linea", "marker-end": "url(#flecha)" }, grupo);
    crear("title", {}, grupo).textContent = `${enlace.id}. ${origen.nombre} → ${destino.nombre}: ${enlace.protocolo}`;

    // La etiqueta va en otra capa para quedar por encima de todas las líneas.
    const etiqueta = crear("text", {
      class: `etiqueta ${enlace.tipo}`, x: medio.x, y: medio.y + 4, "text-anchor": "middle",
    }, capaEtiquetas);
    etiqueta.textContent = enlace.etiqueta;

    const seleccionar = () => {
      marcarActivo(grupo, etiqueta);
      mostrarEnlace(enlace);
    };
    activable(grupo, seleccionar);
    etiqueta.addEventListener("click", seleccionar);
  }

  for (const nodo of grafo.nodos) {
    const grupo = crear("g", {
      class: `nodo ${nodo.capa}`,
      "data-clave": nodo.clave,
      transform: `translate(${nodo.x - ANCHO / 2},${nodo.y - ALTO / 2})`,
    }, capaNodos);
    crear("rect", { width: ANCHO, height: ALTO, rx: 4 }, grupo);
    crear("circle", { class: "punto", cx: ANCHO - 10, cy: 10, r: 4 }, grupo);
    const nombre = crear("text", { class: "nombre", x: ANCHO / 2, y: 25, "text-anchor": "middle" }, grupo);
    nombre.textContent = nodo.nombre;
    const rol = crear("text", { class: "rol", x: ANCHO / 2, y: 43, "text-anchor": "middle" }, grupo);
    rol.textContent = nodo.rol;
    activable(grupo, () => {
      marcarActivo(grupo);
      mostrarNodo(nodo);
    });
  }

  aplicarEstados();
}

function mostrarNodo(nodo) {
  const estado = estados.get(nodo.clave);
  const relacionados = enlaces.filter((e) => e.origen === nodo.clave || e.destino === nodo.clave);
  detalle.innerHTML = `
    <h3>${escapar(nodo.nombre)}</h3>
    <p class="suave">${escapar(nodo.rol)} · capa ${escapar(nodo.capa)} · paso ${nodo.orden}</p>
    <p>${escapar(nodo.descripcion)}</p>
    <dl>
      ${nodo.version ? `<dt>Versión</dt><dd>${escapar(nodo.version)}</dd>` : ""}
      ${nodo.puerto ? `<dt>Puerto</dt><dd>${escapar(nodo.puerto)}</dd>` : ""}
      ${estado ? `<dt>Estado (WildFly)</dt><dd>${estado.ok ? "activo" : "sin respuesta"} · ${estado.milisegundos} ms<br><span class="suave">${escapar(estado.detalle)}</span></dd>` : ""}
      <dt>Enlaces</dt>
      <dd>${relacionados.map((e) => `${e.id}. ${escapar(nombreDe(e.origen))} → ${escapar(nombreDe(e.destino))}`).join("<br>")}</dd>
    </dl>
    <p><a href="${escapar(config.base)}tecnologia/${encodeURIComponent(nodo.clave)}">Documentación de ${escapar(nodo.nombre)} →</a></p>`;
}

function mostrarEnlace(enlace) {
  detalle.innerHTML = `
    <h3>${enlace.id}. ${escapar(nombreDe(enlace.origen))} → ${escapar(nombreDe(enlace.destino))}</h3>
    <p class="suave">${enlace.tipo === "ejecucion" ? "Ejecución" : "Construcción"} · ${escapar(enlace.etiqueta)}</p>
    <dl>
      <dt>Protocolo</dt><dd>${escapar(enlace.protocolo)}</dd>
      <dt>Ida</dt><dd>${escapar(enlace.dato_ida)}</dd>
      <dt>Vuelta</dt><dd>${escapar(enlace.dato_vuelta)}</dd>
      <dt>Transformación</dt><dd>${escapar(enlace.transformacion)}</dd>
    </dl>`;
}

function nombreDe(clave) {
  return nodosPorClave.get(clave)?.nombre ?? clave;
}

function aplicarEstados() {
  for (const grupo of svg.querySelectorAll(".nodo")) {
    const estado = estados.get(grupo.dataset.clave);
    grupo.classList.toggle("ok", estado?.ok === true);
    grupo.classList.toggle("falla", estado?.ok === false);
  }
}

async function cargarGrafo() {
  const linea = document.getElementById("origen-grafo");
  const url = `${config.api}/api/grafo`;
  try {
    const inicio = performance.now();
    const grafo = await obtenerJSON(url);
    dibujar(grafo);
    linea.textContent = `Grafo: ${grafo.nodos.length} nodos y ${grafo.enlaces.length} enlaces desde GET ${url} (${Math.round(performance.now() - inicio)} ms).`;
  } catch (error) {
    linea.textContent = `Grafo: FastAPI no respondió (${error.message}). La lista de enlaces de abajo, generada por CodeIgniter, sigue disponible.`;
  }
}

async function cargarEstado() {
  const linea = document.getElementById("estado");
  const url = `${config.monitor}/api/estado`;
  linea.textContent = "Estado: consultando WildFly…";
  try {
    const verificaciones = await obtenerJSON(url);
    estados.clear();
    for (const v of verificaciones) estados.set(v.servicio, v);
    aplicarEstados();
    linea.textContent = "Estado (GET " + url + "): " + verificaciones
      .map((v) => `${v.servicio} ${v.ok ? "activo" : "sin respuesta"} ${v.milisegundos} ms`)
      .join(" · ");
  } catch (error) {
    linea.textContent = `Estado: WildFly no respondió (${error.message}).`;
  }
}

document.querySelectorAll("[data-filtro]").forEach((boton) => {
  boton.addEventListener("click", () => {
    svg.dataset.filtro = boton.dataset.filtro;
    document.querySelectorAll("[data-filtro]").forEach((b) => b.setAttribute("aria-pressed", String(b === boton)));
  });
});
document.getElementById("reverificar").addEventListener("click", cargarEstado);

// Las dos peticiones salen en paralelo; el estado se aplica cuando el grafo existe.
Promise.allSettled([cargarGrafo(), cargarEstado()]).then(aplicarEstados);
