// Consola fetch: ejecuta las peticiones del sitio y muestra la respuesta sin procesar.

(() => {
  const { api, monitor, base } = document.body.dataset;
  const ENDPOINTS = [
    { nombre: "FastAPI · GET /salud", url: `${api}/salud` },
    { nombre: "FastAPI · GET /api/grafo", url: `${api}/api/grafo` },
    { nombre: "FastAPI · GET /api/tecnologias/sqlserver", url: `${api}/api/tecnologias/sqlserver` },
    { nombre: "FastAPI · GET /api/tecnologias/cobol (404)", url: `${api}/api/tecnologias/cobol` },
    { nombre: "FastAPI · GET /api/verificaciones", url: `${api}/api/verificaciones` },
    { nombre: "WildFly · GET /monitor/api/estado", url: `${monitor}/api/estado` },
    { nombre: "CodeIgniter · GET /salud (mismo origen)", url: `${base}salud` },
  ];
  const MAXIMO = 6000; // caracteres de cuerpo que se muestran

  const selector = document.getElementById("endpoint");
  const boton = document.getElementById("ejecutar");
  const codigo = document.getElementById("consola-codigo");
  const salida = document.getElementById("consola-salida");

  ENDPOINTS.forEach((e, i) => selector.add(new Option(e.nombre, String(i))));

  function mostrarCodigo() {
    const { url } = ENDPOINTS[selector.value];
    codigo.textContent =
`const respuesta = await fetch("${url}", {
  headers: { Accept: "application/json" },
});
console.log(respuesta.status, respuesta.headers.get("content-type"));
const datos = await respuesta.json();`;
  }

  async function ejecutar() {
    const { url } = ENDPOINTS[selector.value];
    salida.textContent = `GET ${url}\n…`;
    const inicio = performance.now();
    try {
      const respuesta = await fetch(url, {
        headers: { Accept: "application/json" },
        signal: AbortSignal.timeout(8000),
      });
      const texto = await respuesta.text();
      const ms = Math.round(performance.now() - inicio);
      let cuerpo = texto;
      try {
        cuerpo = JSON.stringify(JSON.parse(texto), null, 2);
      } catch {
        // no es JSON: se muestra tal cual
      }
      if (cuerpo.length > MAXIMO) {
        cuerpo = `${cuerpo.slice(0, MAXIMO)}\n… (${cuerpo.length - MAXIMO} caracteres más)`;
      }
      salida.textContent = [
        `GET ${url}`,
        `→ ${respuesta.status} ${respuesta.statusText} · ${ms} ms · ${new Blob([texto]).size} bytes`,
        `content-type: ${respuesta.headers.get("content-type")}`,
        `response.ok: ${respuesta.ok}`,
        "",
        cuerpo,
      ].join("\n");
    } catch (error) {
      // Aquí llegan solo los errores de red, CORS o tiempo agotado; nunca un 404.
      salida.textContent = `GET ${url}\n→ ${error.name}: ${error.message}\n\n` +
        "fetch rechaza la promesa solo si no hubo respuesta utilizable: servicio caído, CORS no autorizado o tiempo agotado.";
    }
  }

  selector.addEventListener("change", mostrarCodigo);
  boton.addEventListener("click", ejecutar);
  mostrarCodigo();
})();
