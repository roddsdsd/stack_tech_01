# Stack tecnológico 02

Un proyecto para aprender un stack completo construyéndolo, y que se documenta a sí mismo. El sitio muestra un grafo con las tecnologías como nodos y, en cada enlace, qué dato viaja y cómo se transforma. Cada tecnología tiene una página que explica cómo instalarla, configurarla, conectarla y programarla, con el código real de este repositorio como ejemplo.

| Pieza | Papel | Habla con |
|---|---|---|
| **CodeIgniter 4** (PHP, MVC) | Genera el HTML del sitio | SQL Server (sqlsrv) |
| **FastAPI** (Python) | API JSON del grafo y de la documentación | SQL Server (pyodbc) |
| **WildFly** (Java, Jakarta EE) | Monitor: comprueba los servicios y guarda el historial | SQL Server (JDBC), FastAPI y CodeIgniter (HTTP) |
| **SQL Server 2022** | Guarda todo el contenido del sitio | — |
| **Navegador + fetch** | Dibuja el grafo en SVG con JSON de FastAPI y WildFly | FastAPI, WildFly |
| **Git · Docker · GitHub Actions** | Versionado, contenedores, CI/CD | — |

## Arrancar

Requisito: Docker Desktop (Windows/macOS) o Docker Engine (Linux), con 4 GB de memoria o más.

```bash
cp .env.example .env          # opcional: cambia las contraseñas
docker compose up -d --build  # la primera vez tarda varios minutos
```

| URL | Servicio |
|---|---|
| http://localhost:8080 | Sitio (CodeIgniter) |
| http://localhost:8000/docs | API (FastAPI, documentación interactiva) |
| http://localhost:8081/monitor/api/estado | Monitor (WildFly) |
| `localhost,1433` | SQL Server (usuario `sa`) |

## Estructura

```
db/            T-SQL: esquema, contenido del sitio y usuario de mínimo privilegio
fastapi/       API JSON (app/) y pruebas (tests/)
wildfly/       monitor.war (Maven) y configuración del servidor (configurar.cli)
codeigniter/   app/ (Config, Controllers, Models, Views, Helpers) y public/ (CSS, JS)
.github/       pipeline de CI/CD
```

CodeIgniter se instala con Composer al construir la imagen; el repositorio solo contiene lo que este proyecto añade o cambia sobre el proyecto base (`codeigniter4/appstarter`).

## Cambiar el contenido

Todo el texto del sitio está en [db/02_datos.sql](db/02_datos.sql). Después de editarlo:

```bash
docker compose up db-init     # vuelve a ejecutar los scripts
```

## Qué pesa más en este proyecto

El objetivo es aprender, así que el esfuerzo va a **la información y a que cada integración funcione de verdad**, no al diseño:

1. **Integraciones reales (lo más importante).** Tres lenguajes se conectan a la misma base con tres drivers distintos (sqlsrv, pyodbc, JDBC), dos APIs se llaman desde el navegador con fetch y CORS, y un servicio escribe datos que otro lee. Si una de esas conexiones falla, el sitio lo muestra.
2. **Contenido completo.** Cada tecnología explica instalación, configuración, conexión, el código mínimo, los problemas frecuentes y los archivos reales del repositorio. Cada enlace del grafo describe el protocolo, el dato de ida, el de vuelta y la transformación.
3. **Automatización.** El pipeline prueba cada pieza por separado y después el stack completo.
4. **Diseño (lo menos importante).** HTML semántico, una hoja de estilos y SVG hecho a mano. Sin frameworks de interfaz ni librerías de JavaScript.
