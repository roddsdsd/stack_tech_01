-- =============================================================
-- Stack tecnológico 02 · 02_datos.sql
-- Contenido del sitio: nodos, enlaces, documentación y archivos.
-- Todo el texto usa literales N'...' (Unicode). Una comilla simple
-- dentro del texto se escribe duplicada: ''.
-- Ojo: sqlcmd sustituye variables con la forma dólar + paréntesis
-- en TODOS los scripts, por eso este archivo nunca la usa.
-- =============================================================

USE stack02;
GO

SET NOCOUNT ON;

-- -------------------------------------------------------------
-- Nodos
-- -------------------------------------------------------------
INSERT INTO dbo.tecnologias (clave, nombre, rol, capa, descripcion, version, puerto, x, y, orden) VALUES
(N'git', N'Git', N'Control de versiones', N'herramienta',
 N'Registra cada cambio del proyecto como una serie de commits. Es el punto de partida: las imágenes Docker se construyen desde el repositorio, el pipeline de CI/CD se dispara con cada push y este sitio muestra archivos leídos del propio repositorio.',
 N'Git 2.4x', NULL, 100, 540, 1),

(N'docker', N'Docker', N'Contenedores', N'herramienta',
 N'Empaqueta cada servicio con su sistema operativo, dependencias y configuración en una imagen. Docker Compose arranca los cinco servicios en una red privada donde se encuentran por nombre, así que no hace falta instalar PHP, Python, Java ni SQL Server en tu máquina.',
 N'Docker Engine 27 · Compose v2', NULL, 780, 540, 2),

(N'sqlserver', N'SQL Server', N'Base de datos', N'datos',
 N'Guarda el contenido de este sitio (nodos, enlaces, secciones y archivos) y el historial de verificaciones de WildFly. Tres clientes con drivers distintos (sqlsrv en PHP, pyodbc en Python, JDBC en Java) se conectan a ella con el mismo protocolo: TDS.',
 N'SQL Server 2022 Developer (Linux)', N'1433', 780, 360, 3),

(N'fastapi', N'FastAPI', N'API JSON', N'api',
 N'Expone el grafo y la documentación como JSON. El navegador la consulta con fetch para dibujar el grafo. Valida cada respuesta con Pydantic y genera su propia documentación OpenAPI en /docs.',
 N'FastAPI 0.115 · Python 3.12 · Uvicorn', N'8000', 420, 360, 4),

(N'wildfly', N'WildFly', N'Monitor Jakarta EE', N'servicio',
 N'Servidor de aplicaciones Java. Ejecuta monitor.war, que comprueba SQL Server mediante un DataSource administrado por el servidor y llama por HTTP a FastAPI y CodeIgniter. Guarda cada resultado en la tabla verificaciones y lo devuelve como JSON; el grafo lo usa para marcar los nodos activos.',
 N'WildFly 35 · Jakarta EE 10 · Java 21', N'8081 (8080 en el contenedor)', 780, 120, 5),

(N'codeigniter4', N'CodeIgniter 4', N'Sitio web MVC', N'presentacion',
 N'Genera las páginas HTML que estás leyendo siguiendo el patrón Modelo-Vista-Controlador: los modelos consultan SQL Server, los controladores reúnen los datos de cada página y las vistas los convierten en HTML.',
 N'CodeIgniter 4.6 · PHP 8.3 · Apache 2.4', N'8080 (80 en el contenedor)', 420, 120, 6),

(N'navegador', N'Navegador + fetch', N'Cliente HTML + JS', N'cliente',
 N'Recibe el HTML de CodeIgniter y después, con JavaScript, pide JSON a FastAPI y a WildFly usando fetch. Con esos datos dibuja el grafo en SVG. Sin axios, sin frameworks y sin librerías de grafos.',
 N'ES2022 · Fetch API · SVG', NULL, 100, 280, 7),

(N'cicd', N'GitHub Actions', N'CI/CD', N'herramienta',
 N'Cada push ejecuta el pipeline: pruebas de FastAPI, compilación del WAR, revisión de sintaxis PHP, construcción de las imágenes y una prueba de integración con todo el stack en marcha. En main publica las imágenes en GitHub Container Registry.',
 N'GitHub Actions · ghcr.io', NULL, 420, 540, 8);

-- -------------------------------------------------------------
-- Enlaces (el número de cada fila define su id)
-- -------------------------------------------------------------
INSERT INTO dbo.enlaces (origen_id, destino_id, tipo, etiqueta, protocolo, dato_ida, dato_vuelta, transformacion, curva)
SELECT o.id, d.id, v.tipo, v.etiqueta, v.protocolo, v.ida, v.vuelta, v.transformacion, v.curva
FROM (VALUES
(1, N'navegador', N'codeigniter4', N'ejecucion', N'HTTP · HTML',
 N'HTTP/1.1 GET sobre TCP · localhost:8080 → Apache :80',
 N'Petición GET /tecnologia/{clave} con cabeceras Host, Accept y User-Agent.',
 N'Documento HTML completo (200) o página de error (404). Después el navegador pide /css/estilo.css y los archivos /js/*.js.',
 N'Apache reescribe la URL hacia public/index.php (.htaccess). El Router de CodeIgniter la asocia a Tecnologia::ver(clave). El controlador pide datos a los modelos, recibe arrays PHP y los pasa a la vista, que los inserta en la plantilla escapando cada valor con esc(). Resultado: texto HTML.',
 0),
(2, N'codeigniter4', N'sqlserver', N'ejecucion', N'sqlsrv · TDS',
 N'TDS sobre TCP 1433 · extensión sqlsrv de PHP + ODBC Driver 18',
 N'SQL generado por el Query Builder, por ejemplo SELECT * FROM "dbo"."tecnologias" WHERE "clave" = ? con el valor enviado como parámetro.',
 N'Conjunto de filas (result set).',
 N'El Query Builder convierte llamadas PHP (where, orderBy, first) en SQL del dialecto de SQL Server. La extensión sqlsrv lo entrega al driver ODBC, que lo empaqueta en mensajes TDS. SQL Server analiza, optimiza y ejecuta la consulta. Las filas vuelven y CodeIgniter las convierte en arrays asociativos (returnType = array).',
 60),
(3, N'navegador', N'fastapi', N'ejecucion', N'fetch · JSON',
 N'HTTP/1.1 GET con fetch, petición entre orígenes (CORS) · localhost:8000',
 N'fetch(".../api/grafo") con las cabeceras Accept: application/json y Origin: http://localhost:8080.',
 N'JSON {"nodos": [...], "enlaces": [...]} con la cabecera Access-Control-Allow-Origin.',
 N'Uvicorn (servidor ASGI) recibe la petición; FastAPI la enruta a la función grafo(); el repositorio consulta SQL Server; las filas se validan con los modelos Pydantic Grafo, Nodo y Enlace y se serializan a JSON. En el navegador, response.json() lo convierte en objetos JavaScript y grafo.js los transforma en elementos SVG.',
 0),
(4, N'fastapi', N'sqlserver', N'ejecucion', N'pyodbc · TDS',
 N'TDS sobre TCP 1433 · pyodbc + ODBC Driver 18',
 N'SELECT escrito a mano en repositorio.py, con marcadores ? cuando hay valores.',
 N'Filas que pyodbc entrega como objetos Row.',
 N'cursor.execute envía el SQL y los parámetros por separado; el driver ODBC los convierte en TDS. Las filas recibidas se convierten en diccionarios con los nombres de cursor.description y después en modelos Pydantic, que validan los tipos.',
 0),
(5, N'navegador', N'wildfly', N'ejecucion', N'fetch · JSON',
 N'HTTP/1.1 GET con fetch, CORS · localhost:8081 → Undertow :8080',
 N'fetch(".../monitor/api/estado").',
 N'JSON: lista de objetos {servicio, ok, milisegundos, detalle}.',
 N'Undertow (servidor web de WildFly) recibe la petición; RESTEasy la despacha a EstadoRecurso.estado() por ruta y verbo; el método ejecuta las comprobaciones y devuelve objetos Verificacion; JSON-B los serializa. CorsFiltro añade Access-Control-Allow-Origin. El navegador usa la lista para marcar cada nodo como activo o caído.',
 0),
(6, N'wildfly', N'sqlserver', N'ejecucion', N'JDBC · TDS',
 N'TDS sobre TCP 1433 · driver mssql-jdbc a través de un DataSource JNDI',
 N'SELECT @@VERSION para comprobar la conexión e INSERT INTO verificaciones (por lotes) para registrar el resultado.',
 N'Versión del motor y número de filas insertadas.',
 N'El servidor inyecta el DataSource java:jboss/datasources/Stack02DS. Su pool presta una conexión ya abierta en lugar de abrir una por petición. PreparedStatement envía SQL y parámetros; el driver JDBC los traduce a TDS. Al cerrar la conexión (try-with-resources) vuelve al pool.',
 0),
(7, N'wildfly', N'fastapi', N'ejecucion', N'HTTP · salud',
 N'HTTP/1.1 GET de servidor a servidor · red interna de Docker',
 N'GET http://fastapi:8000/salud (fastapi es el nombre DNS del servicio en compose).',
 N'{"servicio": "fastapi", "ok": true}',
 N'java.net.http.HttpClient hace la petición con un límite de 3 s y mide el tiempo. Un código 200 se traduce en ok = true; cualquier error o tiempo agotado, en ok = false con el mensaje en detalle. Aquí no hay CORS: CORS solo lo aplican los navegadores.',
 60),
(8, N'wildfly', N'codeigniter4', N'ejecucion', N'HTTP · salud',
 N'HTTP/1.1 GET de servidor a servidor · red interna de Docker',
 N'GET http://codeigniter/salud',
 N'{"servicio": "codeigniter4", "ok": true, "bd": {...}}: CodeIgniter a su vez cuenta las filas de tecnologias en SQL Server.',
 N'Igual que con FastAPI: HttpClient, límite de 3 s y tiempo medido. La respuesta de CodeIgniter incluye su propia comprobación de base de datos, así que un ok aquí confirma la cadena WildFly → CodeIgniter → SQL Server.',
 0),
(9, N'git', N'cicd', N'construccion', N'push · commits',
 N'HTTPS o SSH · protocolo de transferencia de Git',
 N'git push origin main: objetos nuevos (commits, árboles y blobs) comprimidos en un packfile.',
 N'Referencia actualizada: main apunta al nuevo commit.',
 N'GitHub guarda los objetos, mueve la rama y emite un evento push. Ese evento dispara el workflow .github/workflows/ci.yml en una máquina virtual que clona exactamente ese commit.',
 0),
(10, N'cicd', N'docker', N'construccion', N'build · imágenes',
 N'API de Docker Engine · registro OCI (ghcr.io)',
 N'Código del commit y Dockerfiles.',
 N'Imágenes etiquetadas ghcr.io/<usuario>/stack-tecnologico-02/<servicio>:latest y :<sha>.',
 N'Cada instrucción de un Dockerfile produce una capa. El resultado es una imagen inmutable que se prueba levantando el stack completo y, en main, se sube al registro.',
 0),
(11, N'docker', N'sqlserver', N'construccion', N'contenedor',
 N'docker compose · red stack02_default',
 N'Imagen mcr.microsoft.com/mssql/server:2022-latest, variables ACCEPT_EULA y MSSQL_SA_PASSWORD y el volumen datos-sql.',
 N'Contenedor sqlserver, considerado sano cuando responde a SELECT 1.',
 N'compose crea la red, el volumen y el contenedor, e inyecta las variables de entorno. Cuando el healthcheck pasa, el servicio db-init ejecuta los tres scripts T-SQL con sqlcmd y termina.',
 0),
(12, N'docker', N'codeigniter4', N'construccion', N'contenedor',
 N'docker compose · build multi-stage',
 N'codeigniter/Dockerfile (PHP 8.3 + Apache + sqlsrv) y las variables DB_* y PUBLIC_*_URL.',
 N'Contenedor codeigniter publicado en localhost:8080.',
 N'Etapa 1: Composer crea el proyecto base de CodeIgniter. Etapa 2: se instala el driver de SQL Server, se copia la aplicación del repositorio encima y el repositorio completo en /proyecto para mostrar sus archivos.',
 80),
(13, N'docker', N'fastapi', N'construccion', N'contenedor',
 N'docker compose',
 N'fastapi/Dockerfile (Python 3.12 + msodbcsql18) y las variables DB_*.',
 N'Contenedor fastapi publicado en localhost:8000.',
 N'Se instala el driver ODBC de Microsoft, luego las dependencias de requirements.txt y por último el código, en ese orden para aprovechar la caché de capas.',
 0),
(14, N'docker', N'wildfly', N'construccion', N'contenedor',
 N'docker compose · build multi-stage',
 N'wildfly/Dockerfile: Maven compila monitor.war y descarga mssql-jdbc; jboss-cli configura driver y DataSource.',
 N'Contenedor wildfly publicado en localhost:8081.',
 N'Etapa 1 (Maven): código Java → monitor.war. Etapa 2 (WildFly): configurar.cli modifica standalone.xml y el WAR se copia a standalone/deployments, donde se despliega al arrancar.',
 200)
) AS v (numero, origen, destino, tipo, etiqueta, protocolo, ida, vuelta, transformacion, curva)
JOIN dbo.tecnologias o ON o.clave = v.origen
JOIN dbo.tecnologias d ON d.clave = v.destino
ORDER BY v.numero;

-- -------------------------------------------------------------
-- Documentación
-- -------------------------------------------------------------
INSERT INTO dbo.secciones (tecnologia_id, orden, titulo, tipo, lenguaje, contenido)
SELECT t.id, v.orden, v.titulo, v.tipo, v.lenguaje, v.contenido
FROM (VALUES

-- ===================== Git =====================
(N'git', 1, N'Qué papel cumple', N'texto', NULL,
N'Git guarda la historia completa del proyecto. Cada commit es una fotografía de todos los archivos junto con un mensaje que explica el cambio. Aquí el repositorio es la fuente de todo lo demás: las imágenes Docker se construyen desde él, el pipeline de CI/CD se dispara con cada `git push` y este sitio muestra archivos leídos del propio repositorio.

Lo que viaja de Git a CI/CD no son archivos sueltos sino objetos: commits que apuntan a árboles (carpetas), que apuntan a blobs (contenido de archivos). Cada objeto se identifica por un hash SHA de su contenido.'),
(N'git', 2, N'Instalación', N'texto', NULL,
N'Windows: Git for Windows (incluye Git Bash). Linux: el gestor de paquetes de la distribución. Comprueba la instalación con `git --version`.'),
(N'git', 3, NULL, N'comando', N'powershell',
N'# Windows (PowerShell)
winget install --id Git.Git -e

# Debian / Ubuntu
sudo apt install git

git --version'),
(N'git', 4, N'Configuración inicial', N'comando', N'bash',
N'git config --global user.name "Tu Nombre"
git config --global user.email "tu@correo.com"
git config --global init.defaultBranch main
# Windows: CRLF en tu copia de trabajo, LF en el repositorio
git config --global core.autocrlf true'),
(N'git', 5, NULL, N'nota', NULL,
N'Los contenedores son Linux. Un archivo con finales de línea CRLF (Windows) puede fallar dentro de ellos. El archivo `.gitattributes` del proyecto fuerza LF en el repositorio para todos los archivos de texto.'),
(N'git', 6, N'Crear el repositorio', N'comando', N'bash',
N'mkdir stack-tecnologico-02
cd stack-tecnologico-02
git init
# ... crear los archivos del proyecto ...
git status
git add .
git commit -m "Estructura inicial del stack"
git log --oneline'),
(N'git', 7, N'Estructura del repositorio', N'codigo', N'text',
N'stack-tecnologico-02/
├── .github/workflows/ci.yml   pipeline CI/CD
├── db/                        scripts T-SQL: esquema, datos, seguridad
├── fastapi/                   API JSON en Python
├── wildfly/                   monitor Jakarta EE en Java (WAR)
├── codeigniter/               sitio MVC en PHP
├── docker-compose.yml         orquestación local
├── .gitignore  .gitattributes  .dockerignore  .env.example
└── README.md'),
(N'git', 8, N'Qué no se versiona', N'texto', NULL,
N'Dependencias descargadas (`vendor/`, `.venv/`), artefactos compilados (`target/`), cachés (`__pycache__/`) y secretos (`.env`). Se regeneran o se configuran en cada máquina y se listan en `.gitignore`.

`.env.example` sí se versiona: documenta qué variables existen sin exponer los valores reales.'),
(N'git', 9, N'Publicar en GitHub', N'comando', N'bash',
N'git remote add origin https://github.com/<usuario>/stack-tecnologico-02.git
git push -u origin main'),
(N'git', 10, N'Flujo de trabajo diario', N'comando', N'bash',
N'git switch -c mejora/grafo        # una rama por cambio
git add -p                        # revisar y elegir fragmentos
git commit -m "Grafo: filtro por tipo de enlace"
git push -u origin mejora/grafo   # en GitHub: abrir un Pull Request
# el pipeline se ejecuta sobre el PR; al fusionar en main publica imágenes
git switch main
git pull'),
(N'git', 11, N'Consultar la historia', N'comando', N'bash',
N'git diff                          # cambios sin preparar
git diff --staged                 # cambios preparados para el commit
git log --oneline --graph --all   # historia como grafo
git show <hash>                   # contenido de un commit
git blame db/02_datos.sql         # quién cambió cada línea
git restore archivo               # descartar cambios locales de un archivo'),

-- ===================== Docker =====================
(N'docker', 1, N'Qué papel cumple', N'texto', NULL,
N'Docker empaqueta cada servicio con su sistema operativo base, sus dependencias y su configuración en una imagen. Docker Compose arranca todas las imágenes como contenedores dentro de una red privada donde cada servicio se encuentra por su nombre: desde FastAPI, el host `sqlserver` resuelve a la IP del contenedor de SQL Server.

Así, para ejecutar el proyecto solo necesitas Docker. PHP, Python, Java, WildFly y SQL Server viven dentro de las imágenes.'),
(N'docker', 2, N'Conceptos', N'texto', NULL,
N'- Imagen: plantilla de solo lectura formada por capas. Se construye con un Dockerfile.
- Contenedor: proceso en ejecución creado a partir de una imagen, con su propio sistema de archivos y su propia red.
- Capa: resultado de cada instrucción del Dockerfile. Docker reutiliza las capas que no cambian (caché); por eso se copian primero los archivos de dependencias y después el código.
- Volumen: almacenamiento que sobrevive al contenedor. Aquí `datos-sql` guarda los archivos de la base de datos.
- Red: compose crea la red `stack02_default` y cada servicio es un nombre DNS dentro de ella.
- Puerto publicado: `8080:80` significa puerto 8080 del host → puerto 80 del contenedor.'),
(N'docker', 3, N'Instalación', N'texto', NULL,
N'Windows: Docker Desktop usa WSL 2 como motor Linux. Activa WSL, instala Docker Desktop, reinicia y ábrelo una vez para que arranque el motor. En Settings → Resources asigna al menos 4 GB de memoria (SQL Server necesita 2 GB). Linux: Docker Engine con el plugin compose.'),
(N'docker', 4, NULL, N'comando', N'powershell',
N'# Windows (PowerShell como administrador)
wsl --install
winget install -e --id Docker.DockerDesktop

# Linux
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

docker version
docker compose version
docker run --rm hello-world'),
(N'docker', 5, N'Anatomía de un Dockerfile', N'codigo', N'dockerfile',
N'FROM python:3.12-slim-bookworm      # imagen base
WORKDIR /srv                        # directorio de trabajo
COPY requirements.txt .             # 1.º dependencias: capa que casi no cambia
RUN pip install -r requirements.txt
COPY app ./app                      # 2.º código: cambia a menudo
EXPOSE 8000                         # documenta el puerto
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]'),
(N'docker', 6, NULL, N'texto', NULL,
N'Construcción en varias etapas (multi-stage): WildFly y CodeIgniter usan una primera etapa con herramientas de compilación (Maven, Composer) y copian a la imagen final solo el resultado. La imagen final es más pequeña y no contiene compiladores.'),
(N'docker', 7, N'docker-compose.yml', N'texto', NULL,
N'El archivo describe cinco servicios. El orden de arranque se controla con `depends_on` y condiciones:

- `sqlserver` declara un `healthcheck` que ejecuta `SELECT 1`; está sano cuando responde.
- `db-init` espera a `service_healthy`, ejecuta los scripts T-SQL con sqlcmd y termina.
- `fastapi`, `wildfly` y `codeigniter` esperan a `service_completed_successfully` de `db-init`: arrancan con la base de datos creada y con datos.

Las variables de conexión se escriben una sola vez en un ancla YAML (`x-bd: &bd`) y cada servicio las reutiliza con `<<: *bd`.'),
(N'docker', 8, N'Comandos esenciales', N'comando', N'bash',
N'docker compose up -d --build      # construir y arrancar todo
docker compose ps                 # estado de cada servicio
docker compose logs -f fastapi    # seguir los registros de un servicio
docker compose logs db-init       # ver la salida de los scripts SQL
docker compose exec sqlserver bash
docker compose restart wildfly
docker compose build codeigniter  # reconstruir una sola imagen
docker compose down               # detener y borrar contenedores
docker compose down -v            # ...y también el volumen de datos'),
(N'docker', 9, N'Puertos', N'texto', NULL,
N'- http://localhost:8080 → codeigniter (Apache :80)
- http://localhost:8000 → fastapi (Uvicorn :8000)
- http://localhost:8081 → wildfly (Undertow :8080)
- localhost,1433 → sqlserver (TDS :1433)'),
(N'docker', 10, N'Variables y secretos', N'texto', NULL,
N'compose lee el archivo `.env` que está junto a docker-compose.yml. Copia `.env.example` a `.env` y cambia las contraseñas. Si no existe, se usan los valores por defecto escritos con la forma `${VARIABLE:-valor}`, pensados solo para aprender en local.'),
(N'docker', 11, N'Problemas frecuentes', N'texto', NULL,
N'- `port is already allocated`: otro programa usa el puerto. Cambia el lado izquierdo del mapeo, por ejemplo `8090:80`.
- SQL Server se detiene al arrancar: la contraseña de sa no cumple la política (8 caracteres o más con mayúsculas, minúsculas, dígitos y símbolos) o Docker tiene menos de 2 GB de memoria.
- Errores `bad interpreter` o `command not found` en scripts: el archivo tiene finales CRLF; revisa `.gitattributes`.
- Cambios de código que no aparecen: la imagen es anterior al cambio; usa `--build`.
- `failed to connect to the docker API`: Docker Desktop no está abierto.'),

-- ===================== SQL Server =====================
(N'sqlserver', 1, N'Qué papel cumple', N'texto', NULL,
N'SQL Server guarda el contenido del sitio: las tecnologías (nodos del grafo), los enlaces entre ellas, las secciones de esta documentación y la lista de archivos del repositorio que se muestran en cada página. También registra el historial de verificaciones que escribe WildFly.

Tres clientes distintos se conectan a la misma base: CodeIgniter con la extensión `sqlsrv` de PHP, FastAPI con `pyodbc` y WildFly con el driver JDBC de Microsoft. Cada uno usa su propia biblioteca, pero todos hablan el mismo protocolo de red: TDS (Tabular Data Stream) sobre TCP en el puerto 1433.'),
(N'sqlserver', 2, N'Instalación con Docker', N'texto', NULL,
N'La imagen oficial es Linux. La edición Developer es gratuita y completa para desarrollo. La contraseña de `sa` debe tener al menos 8 caracteres y combinar mayúsculas, minúsculas, dígitos y símbolos; si no, el contenedor se detiene. En este proyecto el contenedor lo crea compose; el comando equivalente a mano es:'),
(N'sqlserver', 3, NULL, N'comando', N'bash',
N'docker run -d --name sql1 \
  -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Stack02*Clave" \
  -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest

docker logs -f sql1   # esperar: "SQL Server is now ready for client connections"'),
(N'sqlserver', 4, N'Conectarse con sqlcmd', N'texto', NULL,
N'La imagen incluye sqlcmd en /opt/mssql-tools18/bin. La opción `-C` acepta el certificado autofirmado del servidor (equivale a TrustServerCertificate). Cada lote se ejecuta al escribir `GO`.'),
(N'sqlserver', 5, NULL, N'comando', N'sql',
N'docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Stack02*Clave" -C

1> SELECT name FROM sys.databases;
2> GO
1> USE stack02;
2> SELECT clave, nombre, orden FROM tecnologias ORDER BY orden;
3> GO
1> SELECT TOP 5 servicio, ok, milisegundos, fecha FROM verificaciones ORDER BY id DESC;
2> GO
1> EXIT'),
(N'sqlserver', 6, N'Clientes gráficos', N'texto', NULL,
N'SSMS (Windows) o la extensión SQL Server (mssql) de VS Code. Servidor: `localhost,1433` (en SQL Server el puerto se separa con coma, no con dos puntos). Autenticación SQL, usuario `sa` y la opción de confiar en el certificado del servidor activada.'),
(N'sqlserver', 7, N'Modelo de datos', N'texto', NULL,
N'- `tecnologias`: un nodo del grafo por fila, con su posición (x, y) en el lienzo y su orden de construcción.
- `enlaces`: aristas dirigidas origen → destino con protocolo, dato de ida, dato de vuelta y transformación. `tipo` distingue ejecución (peticiones en vivo) de construcción (Git, CI/CD, Docker).
- `secciones`: bloques de documentación de cada tecnología: texto, comando, código o nota.
- `archivos`: rutas de archivos del repositorio que se muestran en cada página.
- `verificaciones`: historial que escribe WildFly cada vez que comprueba los servicios.
- `v_enlaces` (vista): une `enlaces` con `tecnologias` para obtener claves y nombres sin repetir el JOIN en cada cliente.'),
(N'sqlserver', 8, N'Inicialización', N'texto', NULL,
N'A diferencia de las imágenes de MySQL o PostgreSQL, la de SQL Server no ejecuta scripts al arrancar. Por eso compose define un servicio de un solo uso, `db-init`, que reutiliza la misma imagen solo para tener sqlcmd, espera a que el servidor esté sano y ejecuta los tres scripts en orden:'),
(N'sqlserver', 9, NULL, N'comando', N'bash',
N'sqlcmd -S sqlserver -U sa -P "..." -C -b -f 65001 \
  -v APP_PASSWORD=... \
  -i /db/01_esquema.sql,/db/02_datos.sql,/db/03_seguridad.sql

# -b        termina con error si un script falla (db-init sale con código distinto de 0)
# -f 65001  lee los archivos como UTF-8: tildes y eñes correctas
# -v        define variables de sqlcmd que 03_seguridad.sql usa para la contraseña'),
(N'sqlserver', 10, NULL, N'nota', NULL,
N'sqlcmd busca variables (signo de dólar seguido del nombre entre paréntesis) en todos los scripts que ejecuta, también dentro de textos. Si un texto contiene esa forma, sqlcmd intentará sustituirla. Por eso 02_datos.sql no la usa en ningún lugar.'),
(N'sqlserver', 11, N'Seguridad: un usuario para las aplicaciones', N'texto', NULL,
N'Las aplicaciones no usan `sa`. 03_seguridad.sql crea el login `stack_app`, lo asocia a un usuario de la base `stack02`, le da lectura con el rol `db_datareader` y solo permiso de INSERT en `verificaciones`. Si alguien lograra inyectar SQL en una aplicación, no podría borrar ni modificar tablas.'),
(N'sqlserver', 12, N'Cadena de conexión de cada cliente', N'codigo', N'text',
N'PHP · sqlsrv (lo arma CodeIgniter con app/Config/Database.php)
  sqlsrv_connect("sqlserver, 1433", ["Database" => "stack02", "UID" => "stack_app",
                                     "PWD" => "...", "CharacterSet" => "UTF-8"])

Python · pyodbc (fastapi/app/db.py)
  DRIVER={ODBC Driver 18 for SQL Server};SERVER=sqlserver,1433;DATABASE=stack02;
  UID=stack_app;PWD={...};Encrypt=yes;TrustServerCertificate=yes

Java · JDBC (DataSource de WildFly, wildfly/configurar.cli)
  jdbc:sqlserver://sqlserver:1433;databaseName=stack02;encrypt=true;trustServerCertificate=true'),
(N'sqlserver', 13, NULL, N'nota', NULL,
N'Usa NVARCHAR y literales N''texto'' para guardar texto con tildes. VARCHAR depende de la intercalación (collation) y puede perder caracteres.'),
(N'sqlserver', 14, N'Problemas frecuentes', N'texto', NULL,
N'- `Login failed for user`: contraseña incorrecta, o la base todavía no existe porque db-init no terminó. Revisa `docker compose logs db-init`.
- `certificate verify failed` o `SSL Provider`: el driver 18 cifra por defecto; en desarrollo añade TrustServerCertificate=yes.
- `Invalid object name`: la tabla no existe o la conexión apunta a otra base (falta DATABASE=stack02).
- Signos ? en lugar de tildes: columnas VARCHAR o script leído sin `-f 65001`.'),

-- ===================== FastAPI =====================
(N'fastapi', 1, N'Qué papel cumple', N'texto', NULL,
N'FastAPI expone el contenido de la base de datos como JSON. El navegador la llama con fetch para dibujar el grafo, y cualquier otro cliente podría usarla: una app móvil, un script u otro servicio. No genera HTML, solo datos.

Cada respuesta pasa por un modelo Pydantic que valida los tipos y define la forma del JSON. Con esa información FastAPI genera la especificación OpenAPI y una página interactiva en /docs.'),
(N'fastapi', 2, N'Endpoints', N'texto', NULL,
N'- `GET /salud`: comprobación simple; la usa WildFly.
- `GET /api/grafo`: nodos y enlaces para dibujar el grafo.
- `GET /api/tecnologias`: tecnologías en orden de construcción.
- `GET /api/tecnologias/{clave}`: una tecnología con sus secciones; 404 si no existe.
- `GET /api/verificaciones`: las últimas 20 verificaciones que registró WildFly.
- `GET /docs` y `GET /openapi.json`: documentación generada automáticamente.'),
(N'fastapi', 3, N'Instalación local (sin Docker)', N'texto', NULL,
N'Necesitas Python 3.12 y el ODBC Driver 18 for SQL Server. Un entorno virtual aísla las dependencias del proyecto. Con el stack de compose en marcha, SQL Server está publicado en localhost:1433.'),
(N'fastapi', 4, NULL, N'comando', N'powershell',
N'winget install -e --id Python.Python.3.12
winget install -e --id Microsoft.msodbcsql.18

cd fastapi
python -m venv .venv
.venv\Scripts\Activate.ps1            # Linux / macOS: source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt

$env:DB_HOST = "localhost"
$env:DB_PASSWORD = "App02*Clave"
uvicorn app.main:app --reload --port 8001   # 8000 ya lo usa el contenedor'),
(N'fastapi', 5, N'La API más pequeña posible', N'codigo', N'python',
N'from fastapi import FastAPI

app = FastAPI()

@app.get("/hola/{nombre}")
def hola(nombre: str) -> dict:
    return {"mensaje": f"Hola, {nombre}"}

# uvicorn main:app --reload  →  http://127.0.0.1:8000/hola/mundo'),
(N'fastapi', 6, N'Organización del código', N'texto', NULL,
N'- `app/db.py`: arma la cadena de conexión con variables de entorno y abre la conexión pyodbc.
- `app/repositorio.py`: todo el SQL; convierte filas en diccionarios.
- `app/modelos.py`: modelos Pydantic, es decir, el contrato del JSON.
- `app/main.py`: la aplicación, CORS y las rutas. Las rutas reciben el repositorio por inyección de dependencias (`Depends`).'),
(N'fastapi', 7, N'Conexión a SQL Server', N'texto', NULL,
N'`obtener_repositorio` es una dependencia con `yield`. FastAPI ejecuta lo que está antes del yield antes de la ruta (abre la conexión) y lo que está después al terminar la respuesta (la cierra), incluso si hubo un error.

Las consultas usan marcadores `?`. El driver envía los valores separados del texto SQL, así que un valor nunca se interpreta como código: es la defensa contra la inyección SQL.'),
(N'fastapi', 8, N'Cómo se transforma el dato', N'texto', NULL,
N'fila TDS → `pyodbc.Row` → `dict` (repositorio) → modelo Pydantic (validación) → JSON (serialización) → bytes HTTP con `Content-Type: application/json`.'),
(N'fastapi', 9, N'CORS', N'texto', NULL,
N'El sitio se sirve desde http://localhost:8080 y la API desde http://localhost:8000: son orígenes distintos. El navegador solo entrega la respuesta al JavaScript de la página si la API la autoriza con la cabecera `Access-Control-Allow-Origin`. `CORSMiddleware` la añade para los orígenes de la variable `ORIGENES_PERMITIDOS`.

CORS no protege la API de otros clientes (curl la llama sin problema): protege al usuario del navegador de que una página ajena lea datos en su nombre.'),
(N'fastapi', 10, N'Pruebas', N'texto', NULL,
N'Las pruebas sustituyen el repositorio real por uno falso con `app.dependency_overrides`. No necesitan SQL Server ni el driver ODBC, y por eso el pipeline las ejecuta en segundos.'),
(N'fastapi', 11, NULL, N'comando', N'bash',
N'cd fastapi
pytest -q'),
(N'fastapi', 12, N'Probar la API', N'comando', N'bash',
N'curl http://localhost:8000/salud
curl http://localhost:8000/api/tecnologias/sqlserver
curl -i -H "Origin: http://localhost:8080" http://localhost:8000/api/grafo   # ver la cabecera CORS
# o abrir http://localhost:8000/docs y usar "Try it out"'),

-- ===================== WildFly =====================
(N'wildfly', 1, N'Qué papel cumple', N'texto', NULL,
N'WildFly es un servidor de aplicaciones Jakarta EE: un proceso Java que ofrece servicios ya hechos (HTTP, REST, inyección de dependencias, pools de conexiones, transacciones) a las aplicaciones que se despliegan en él como archivos WAR.

Aquí ejecuta `monitor.war`, que expone `GET /monitor/api/estado`. Cada llamada comprueba SQL Server a través de un DataSource que administra el servidor, y FastAPI y CodeIgniter por HTTP. Mide cuánto tarda cada uno, guarda el resultado en la tabla `verificaciones` y lo devuelve como JSON. El grafo usa esa respuesta para marcar qué nodos están activos.'),
(N'wildfly', 2, N'Conceptos', N'texto', NULL,
N'- WAR: archivo zip con clases compiladas y recursos web. Su nombre define la ruta: `monitor.war` → `/monitor`.
- Jakarta REST (JAX-RS): anotaciones `@Path`, `@GET` y `@Produces` que convierten métodos Java en endpoints HTTP. En WildFly lo implementa RESTEasy.
- CDI: inyección de dependencias. `@RequestScoped` crea una instancia del recurso por petición.
- JNDI: directorio de nombres del servidor. El DataSource se publica como `java:jboss/datasources/Stack02DS`.
- DataSource: pool de conexiones que configura el servidor, no la aplicación. La aplicación solo pide una conexión por su nombre y no conoce la contraseña.
- Módulo: biblioteca instalada en el servidor (aquí, el driver JDBC) que pueden usar varios despliegues.'),
(N'wildfly', 3, N'Instalación local (sin Docker)', N'comando', N'powershell',
N'winget install -e --id EclipseAdoptium.Temurin.21.JDK
winget install -e --id Apache.Maven
java -version
mvn -version

# WildFly: descargar el zip de https://www.wildfly.org/downloads y descomprimir
cd wildfly-35.0.1.Final\bin
.\standalone.bat           # Linux: ./standalone.sh
# http://localhost:8080 aplicaciones · http://localhost:9990 administración
.\add-user.bat             # usuario para la consola de administración'),
(N'wildfly', 4, N'Configurar el driver y el DataSource', N'texto', NULL,
N'Se hace con jboss-cli, la consola de administración en línea de comandos. `configurar.cli` se ejecuta al construir la imagen con el servidor embebido (sin arrancarlo de verdad) y modifica standalone.xml:

- `module add` registra el jar de mssql-jdbc como módulo.
- `jdbc-driver=sqlserver:add` declara el driver a partir de ese módulo.
- `data-source add` crea el pool con la URL JDBC. Los valores `${env.DB_HOST:sqlserver}` son expresiones: WildFly las resuelve al arrancar con las variables de entorno del contenedor, o usa el valor que sigue a los dos puntos si no existen.'),
(N'wildfly', 5, NULL, N'comando', N'bash',
N'jboss-cli.sh --file=configurar.cli

# contra un servidor en marcha, de forma interactiva:
jboss-cli.sh --connect
/subsystem=datasources/data-source=Stack02DS:test-connection-in-pool
/subsystem=datasources/data-source=Stack02DS:read-resource'),
(N'wildfly', 6, N'El código mínimo', N'codigo', N'java',
N'@ApplicationPath("/api")                  // rutas REST bajo /monitor/api
public class AplicacionMonitor extends Application {}

@Path("/estado")
@RequestScoped
public class EstadoRecurso {
    @Resource(lookup = "java:jboss/datasources/Stack02DS")
    private DataSource baseDatos;         // lo inyecta el servidor

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<Verificacion> estado() { ... }   // JSON-B convierte la lista en JSON
}'),
(N'wildfly', 7, N'Cómo se transforma el dato', N'texto', NULL,
N'petición HTTP → Undertow → RESTEasy elige el método por ruta y verbo → objetos Java `Verificacion` → JSON-B (Yasson) los serializa → JSON.

Hacia SQL Server: `PreparedStatement` → driver JDBC → paquetes TDS. Hacia FastAPI y CodeIgniter: `HttpClient` → petición HTTP → código de estado y tiempo medido.'),
(N'wildfly', 8, N'Dependencias con Maven', N'texto', NULL,
N'pom.xml declara una sola dependencia, `jakarta.jakartaee-api`, con `scope provided`: se compila contra las interfaces de Jakarta EE pero no se incluyen en el WAR, porque el servidor ya las tiene. Por eso el WAR pesa unos pocos kilobytes.'),
(N'wildfly', 9, N'Construir y desplegar', N'comando', N'powershell',
N'cd wildfly
mvn package                      # genera target\monitor.war
copy target\monitor.war $env:WILDFLY_HOME\standalone\deployments\
# WildFly lo detecta y crea monitor.war.deployed (o monitor.war.failed con el error)

curl http://localhost:8081/monitor/api/estado   # con Docker'),
(N'wildfly', 10, N'Problemas frecuentes', N'texto', NULL,
N'- `monitor.war.failed`: el archivo contiene el error. Con Docker: `docker compose logs wildfly`.
- `WFLYCTL0412: Required services that are not installed` con Stack02DS: el DataSource no existe o tiene otro nombre JNDI.
- `Login failed` en la verificación de SQL Server: DB_PASSWORD no coincide con la que creó db-init.
- 404 en /monitor/api/estado: revisa el nombre del WAR (contexto) y `@ApplicationPath`.'),

-- ===================== CodeIgniter 4 =====================
(N'codeigniter4', 1, N'Qué papel cumple', N'texto', NULL,
N'CodeIgniter 4 genera las páginas HTML de este sitio. Es un framework PHP ligero que sigue el patrón Modelo-Vista-Controlador (MVC): separa el acceso a datos, la lógica de cada página y la presentación.'),
(N'codeigniter4', 2, N'El patrón MVC en este proyecto', N'texto', NULL,
N'- Modelo (`app/Models`): una clase por tabla. `TecnologiaModel`, `SeccionModel`, `ArchivoModel` y `EnlaceModel` (sobre la vista `v_enlaces`) consultan SQL Server con el Query Builder y devuelven arrays.
- Vista (`app/Views`): plantillas PHP que solo muestran datos. `plantilla.php` define la estructura común; `inicio.php` y `tecnologia.php` la extienden.
- Controlador (`app/Controllers`): recibe la petición, pide datos a los modelos y elige la vista. `Inicio` (portada), `Tecnologia` (cada página de documentación) y `Salud` (JSON para WildFly).
- Rutas (`app/Config/Routes.php`): asocian cada URL a un método de un controlador.
- Helper (`app/Helpers/texto_helper.php`): funciones de presentación que convierten el texto de `secciones` en HTML.'),
(N'codeigniter4', 3, N'Ciclo de una petición', N'texto', NULL,
N'Apache recibe `GET /tecnologia/fastapi` → `public/.htaccess` reescribe hacia `public/index.php` → CodeIgniter arranca y el Router encuentra la ruta `tecnologia/(:segment)` → ejecuta `Tecnologia::ver("fastapi")` → los modelos generan y ejecutan SQL → el controlador pasa los arrays a la vista → la vista produce HTML con los valores escapados por `esc()` → la respuesta vuelve por Apache al navegador.'),
(N'codeigniter4', 4, N'Instalación local (sin Docker)', N'texto', NULL,
N'Requisitos: PHP 8.1 o superior con las extensiones intl y mbstring, y Composer. El servidor de desarrollo integrado (`php spark serve`) evita configurar Apache.'),
(N'codeigniter4', 5, NULL, N'comando', N'bash',
N'composer create-project codeigniter4/appstarter sitio
cd sitio
copy env .env                 # Linux: cp env .env
php spark serve               # http://localhost:8080'),
(N'codeigniter4', 6, N'Driver de SQL Server para PHP', N'texto', NULL,
N'CodeIgniter usa la extensión `sqlsrv` de Microsoft, que a su vez necesita el ODBC Driver 18.

- Linux (como en el Dockerfile): instalar msodbcsql18 desde el repositorio de Microsoft y después `pecl install sqlsrv`.
- Windows: descargar Microsoft Drivers for PHP for SQL Server, copiar a la carpeta `ext` la DLL que corresponde a tu PHP (por ejemplo `php_sqlsrv_83_ts_x64.dll`) y añadir `extension=sqlsrv_83_ts_x64` en php.ini.
- Comprobar: `php -m` debe listar `sqlsrv`.'),
(N'codeigniter4', 7, N'Configurar la conexión', N'texto', NULL,
N'Opción 1: el archivo `.env` (no se versiona).'),
(N'codeigniter4', 8, NULL, N'codigo', N'ini',
N'CI_ENVIRONMENT = development

database.default.hostname = localhost
database.default.database = stack02
database.default.username = stack_app
database.default.password = App02*Clave
database.default.DBDriver = SQLSRV
database.default.port     = 1433'),
(N'codeigniter4', 9, NULL, N'texto', NULL,
N'Opción 2, la usada aquí: `app/Config/Database.php` lee en su constructor las variables de entorno DB_HOST, DB_NAME, DB_USER y DB_PASSWORD, las mismas que usan FastAPI y WildFly en docker-compose.yml.'),
(N'codeigniter4', 10, N'Ruta, modelo, controlador y vista mínimos', N'codigo', N'php',
N'// app/Config/Routes.php
$routes->get("tecnologia/(:segment)", "Tecnologia::ver/$1");

// app/Models/TecnologiaModel.php
class TecnologiaModel extends Model
{
    protected $table      = "tecnologias";
    protected $returnType = "array";
}

// app/Controllers/Tecnologia.php
public function ver(string $clave): string
{
    $tecnologia = (new TecnologiaModel())->where("clave", $clave)->first();
    return view("tecnologia", ["tecnologia" => $tecnologia]);
}

// app/Views/tecnologia.php
<h1><?= esc($tecnologia["nombre"]) ?></h1>'),
(N'codeigniter4', 11, N'Spark: la consola de CodeIgniter', N'comando', N'bash',
N'php spark routes                    # lista de rutas
php spark make:controller Ejemplo   # genera un controlador
php spark make:model EjemploModel   # genera un modelo
php spark db:table tecnologias      # muestra una tabla de la base de datos'),
(N'codeigniter4', 12, N'Archivos del repositorio en la documentación', N'texto', NULL,
N'El Dockerfile copia el repositorio completo en `/proyecto` dentro de la imagen. La tabla `archivos` indica qué rutas mostrar en cada página. El controlador `Tecnologia` solo lee rutas registradas en esa tabla y comprueba con `realpath` que queden dentro de `/proyecto`, para que una ruta manipulada no pueda leer otros archivos del sistema.'),
(N'codeigniter4', 13, N'Problemas frecuentes', N'texto', NULL,
N'- `Call to undefined function sqlsrv_connect()`: la extensión no está cargada (`php -m`).
- Página de error genérica: en producción los detalles se ocultan; mira `writable/logs` o cambia CI_ENVIRONMENT a development.
- 404 en todas las rutas salvo la portada: falta `mod_rewrite` o `AllowOverride All` en Apache.
- CSS y JS que no cargan: `baseURL` incorrecta; aquí se define con la variable de entorno `app_baseURL`.'),

-- ===================== Navegador + fetch =====================
(N'navegador', 1, N'Qué papel cumple', N'texto', NULL,
N'El navegador es el nodo que combina a todos los demás. Primero recibe HTML completo de CodeIgniter. Después, el JavaScript de la página hace peticiones con fetch a FastAPI (el grafo) y a WildFly (el estado de los servicios) y transforma esos JSON en elementos SVG. No hay librerías: ni axios, ni frameworks, ni librerías de grafos.'),
(N'navegador', 2, N'fetch en lo esencial', N'codigo', N'javascript',
N'const respuesta = await fetch("http://localhost:8000/api/grafo", {
  headers: { Accept: "application/json" },
  signal: AbortSignal.timeout(5000),      // cancelar si tarda más de 5 s
});
if (!respuesta.ok) {                       // fetch NO lanza error con 404 o 500
  throw new Error(`HTTP ${respuesta.status}`);
}
const grafo = await respuesta.json();      // segunda promesa: leer y convertir el cuerpo'),
(N'navegador', 3, N'fetch frente a axios', N'texto', NULL,
N'- fetch es parte del navegador: cero dependencias y cero bytes extra.
- fetch solo rechaza la promesa por errores de red. Un 404 o un 500 llega como respuesta normal y hay que revisar `response.ok`; axios rechaza automáticamente.
- fetch no convierte JSON por sí solo: hay que llamar a `response.json()` y, para enviar, `JSON.stringify` con la cabecera Content-Type.
- Para limitar el tiempo se usa `AbortSignal.timeout()` o un `AbortController`; axios tiene la opción timeout.
- axios ofrece interceptores; con fetch se escribe una función propia que centraliza el manejo, como `obtenerJSON` en grafo.js.'),
(N'navegador', 4, N'Enviar datos con fetch', N'codigo', N'javascript',
N'await fetch(url, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ servicio: "fastapi" }),
});
// Content-Type: application/json convierte la petición en "no simple":
// el navegador envía antes una petición OPTIONS (preflight) que el servidor debe aceptar.'),
(N'navegador', 5, N'CORS desde el navegador', N'texto', NULL,
N'La página vive en http://localhost:8080. Cuando pide datos a :8000 o :8081, el navegador añade la cabecera `Origin: http://localhost:8080` y solo entrega la respuesta al código si el servidor contesta con `Access-Control-Allow-Origin` igual a ese origen (o `*`).

Si falta, la petición llega al servidor, pero JavaScript recibe `TypeError: Failed to fetch` y la consola muestra el bloqueo CORS. Por la misma regla, desde otro origen solo se pueden leer ciertas cabeceras de la respuesta (como Content-Type), salvo que el servidor exponga más con `Access-Control-Expose-Headers`.'),
(N'navegador', 6, N'Del JSON al SVG', N'texto', NULL,
N'- `obtenerJSON(url)` envuelve fetch y convierte las respuestas no exitosas en errores.
- Cada nodo de `/api/grafo` trae las coordenadas `x` e `y` guardadas en SQL Server; se dibuja como un grupo `<g>` con un rectángulo y dos textos.
- Cada enlace es una curva cuadrática (`<path d="M … Q … …">`) recortada al borde de los rectángulos y con punta de flecha (`<marker>`). La columna `curva` define cuánto se aparta de la línea recta.
- Al hacer clic en un nodo o en un enlace, el panel lateral muestra sus datos.
- En paralelo se consulta `/monitor/api/estado` y cada nodo verificado recibe la clase `ok` o `falla`.'),
(N'navegador', 7, N'Ver lo que viaja', N'texto', NULL,
N'Abre las herramientas de desarrollo (F12), pestaña Red (Network), y recarga la portada. Verás la petición del documento HTML, las de CSS y JS y las dos peticiones fetch con sus cabeceras y su JSON. La consola fetch de la portada muestra lo mismo dentro de la página.'),

-- ===================== GitHub Actions =====================
(N'cicd', 1, N'Qué papel cumple', N'texto', NULL,
N'Integración continua (CI): cada push o Pull Request ejecuta automáticamente pruebas y construcciones para detectar errores antes de fusionar. Entrega continua (CD): cuando el cambio llega a main y todo pasa, se publican las imágenes Docker listas para desplegar.

El pipeline está en `.github/workflows/ci.yml` y se ejecuta en máquinas virtuales Ubuntu de GitHub, que ya traen Docker.'),
(N'cicd', 2, N'Anatomía de un workflow', N'texto', NULL,
N'- `on`: eventos que lo disparan (push a main, pull_request).
- `jobs`: trabajos; se ejecutan en paralelo salvo que declaren `needs`.
- `runs-on`: tipo de máquina.
- `steps`: pasos en orden. `uses` ejecuta una acción reutilizable (por ejemplo `actions/checkout`) y `run` ejecuta comandos de shell.
- `if`: condición; el job de publicación solo corre en un push a main.
- `permissions`: permisos del token automático `GITHUB_TOKEN`.'),
(N'cicd', 3, N'Trabajos de este proyecto', N'texto', NULL,
N'- `fastapi`: instala Python 3.12 y ejecuta pytest (sin base de datos, gracias al repositorio falso).
- `wildfly`: instala Java 21 y compila el WAR con Maven.
- `codeigniter`: instala PHP 8.3 y revisa la sintaxis de cada archivo con `php -l`.
- `integracion`: si los tres anteriores pasan, levanta el stack completo con docker compose y consulta con curl los endpoints reales de cada servicio.
- `publicar`: solo en main; construye y sube las tres imágenes a GitHub Container Registry (ghcr.io) con las etiquetas `latest` y el hash del commit.'),
(N'cicd', 4, N'Prueba de integración', N'codigo', N'bash',
N'docker compose up -d --build
curl -fsS --retry 40 --retry-delay 5 --retry-all-errors http://localhost:8000/api/grafo
curl -fsS --retry 40 --retry-delay 5 --retry-all-errors http://localhost:8080/tecnologia/sqlserver
curl -fsS --retry 40 --retry-delay 5 --retry-all-errors http://localhost:8081/monitor/api/estado'),
(N'cicd', 5, NULL, N'texto', NULL,
N'`--retry-all-errors` repite mientras el servicio aún arranca (conexión rechazada o error 5xx). `-f` hace que curl falle con códigos 4xx y 5xx, y eso hace fallar el paso y el job. Si algo falla, el paso siguiente imprime `docker compose logs`.'),
(N'cicd', 6, N'Publicar imágenes (CD)', N'texto', NULL,
N'El job `publicar` inicia sesión en ghcr.io con el `GITHUB_TOKEN` (requiere `permissions: packages: write`) y usa una matriz para construir las tres imágenes con `docker/build-push-action`.

Para desplegar en un servidor se usa un compose de producción que referencia las imágenes publicadas (`image: ghcr.io/...`) en lugar de construirlas (`build:`). Actualizar es descargar y recrear:'),
(N'cicd', 7, NULL, N'comando', N'bash',
N'docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d'),
(N'cicd', 8, N'Secretos', N'texto', NULL,
N'Las contraseñas reales no se escriben en el workflow. Se guardan en Settings → Secrets and variables → Actions y se leen como `${{ secrets.NOMBRE }}`. Este pipeline usa los valores por defecto en la prueba de integración porque esa base de datos es temporal y se destruye al terminar.'),
(N'cicd', 9, N'Ver el pipeline', N'texto', NULL,
N'Pestaña Actions del repositorio en GitHub: cada ejecución muestra sus jobs, sus pasos y los registros. Una marca verde junto al commit o en el Pull Request indica que todo pasó.')

) AS v (clave, orden, titulo, tipo, lenguaje, contenido)
JOIN dbo.tecnologias t ON t.clave = v.clave;

-- -------------------------------------------------------------
-- Archivos del repositorio mostrados en cada página
-- -------------------------------------------------------------
INSERT INTO dbo.archivos (tecnologia_id, orden, ruta, descripcion)
SELECT t.id, v.orden, v.ruta, v.descripcion
FROM (VALUES
(N'git', 1, N'.gitignore', N'Lo que Git no debe registrar.'),
(N'git', 2, N'.gitattributes', N'Finales de línea LF en el repositorio.'),
(N'git', 3, N'README.md', N'Punto de entrada del repositorio.'),

(N'docker', 1, N'docker-compose.yml', N'Los cinco servicios, su orden de arranque, puertos y variables.'),
(N'docker', 2, N'.env.example', N'Plantilla de variables secretas.'),
(N'docker', 3, N'.dockerignore', N'Lo que no se copia a la imagen de CodeIgniter.'),

(N'sqlserver', 1, N'db/01_esquema.sql', N'Base de datos, tablas y vista.'),
(N'sqlserver', 2, N'db/03_seguridad.sql', N'Login y permisos de mínimo privilegio.'),
(N'sqlserver', 3, N'db/02_datos.sql', N'Todo el contenido de este sitio.'),

(N'fastapi', 1, N'fastapi/app/main.py', N'Aplicación, CORS, dependencias y rutas.'),
(N'fastapi', 2, N'fastapi/app/db.py', N'Cadena de conexión y conexión pyodbc.'),
(N'fastapi', 3, N'fastapi/app/repositorio.py', N'Consultas SQL.'),
(N'fastapi', 4, N'fastapi/app/modelos.py', N'Modelos Pydantic: el contrato del JSON.'),
(N'fastapi', 5, N'fastapi/tests/test_api.py', N'Pruebas con repositorio falso.'),
(N'fastapi', 6, N'fastapi/requirements.txt', N'Dependencias.'),
(N'fastapi', 7, N'fastapi/Dockerfile', N'Imagen: Python + ODBC Driver 18.'),

(N'wildfly', 1, N'wildfly/src/main/java/st02/monitor/EstadoRecurso.java', N'Endpoint /api/estado: comprueba y registra.'),
(N'wildfly', 2, N'wildfly/src/main/java/st02/monitor/AplicacionMonitor.java', N'Activa Jakarta REST bajo /api.'),
(N'wildfly', 3, N'wildfly/src/main/java/st02/monitor/Verificacion.java', N'Objeto que se serializa a JSON.'),
(N'wildfly', 4, N'wildfly/src/main/java/st02/monitor/CorsFiltro.java', N'Cabecera CORS en cada respuesta.'),
(N'wildfly', 5, N'wildfly/configurar.cli', N'Driver JDBC y DataSource con jboss-cli.'),
(N'wildfly', 6, N'wildfly/pom.xml', N'Proyecto Maven que produce monitor.war.'),
(N'wildfly', 7, N'wildfly/Dockerfile', N'Imagen multi-stage: Maven y WildFly.'),

(N'codeigniter4', 1, N'codeigniter/app/Config/Routes.php', N'Rutas: URL → controlador.'),
(N'codeigniter4', 2, N'codeigniter/app/Config/Database.php', N'Conexión SQLSRV con variables de entorno.'),
(N'codeigniter4', 3, N'codeigniter/app/Controllers/BaseController.php', N'Datos comunes a todas las páginas.'),
(N'codeigniter4', 4, N'codeigniter/app/Controllers/Inicio.php', N'Controlador de la portada.'),
(N'codeigniter4', 5, N'codeigniter/app/Controllers/Tecnologia.php', N'Controlador de cada página de documentación.'),
(N'codeigniter4', 6, N'codeigniter/app/Controllers/Salud.php', N'JSON de salud para WildFly.'),
(N'codeigniter4', 7, N'codeigniter/app/Models/TecnologiaModel.php', N'Modelo de la tabla tecnologias.'),
(N'codeigniter4', 8, N'codeigniter/app/Models/EnlaceModel.php', N'Modelo sobre la vista v_enlaces.'),
(N'codeigniter4', 9, N'codeigniter/app/Models/SeccionModel.php', N'Modelo de la tabla secciones.'),
(N'codeigniter4', 10, N'codeigniter/app/Models/ArchivoModel.php', N'Modelo de la tabla archivos.'),
(N'codeigniter4', 11, N'codeigniter/app/Views/plantilla.php', N'Vista: estructura común.'),
(N'codeigniter4', 12, N'codeigniter/app/Views/inicio.php', N'Vista: portada con el grafo.'),
(N'codeigniter4', 13, N'codeigniter/app/Views/tecnologia.php', N'Vista: página de documentación.'),
(N'codeigniter4', 14, N'codeigniter/app/Helpers/texto_helper.php', N'Texto de secciones → HTML.'),
(N'codeigniter4', 15, N'codeigniter/Dockerfile', N'Imagen: Composer, PHP, Apache y sqlsrv.'),
(N'codeigniter4', 16, N'codeigniter/apache.conf', N'Virtual host de Apache.'),

(N'navegador', 1, N'codeigniter/public/js/grafo.js', N'fetch a FastAPI y WildFly; JSON → SVG.'),
(N'navegador', 2, N'codeigniter/public/js/consola.js', N'Consola fetch de la portada.'),
(N'navegador', 3, N'codeigniter/public/css/estilo.css', N'Estilos del sitio.'),

(N'cicd', 1, N'.github/workflows/ci.yml', N'Pipeline completo de CI/CD.')
) AS v (clave, orden, ruta, descripcion)
JOIN dbo.tecnologias t ON t.clave = v.clave;
GO
