<?= $this->extend('plantilla') ?>

<?= $this->section('contenido') ?>

<section class="intro">
    <h1>Stack tecnológico 02</h1>
    <p>Un proyecto que se documenta a sí mismo: cada página explica cómo instalar, configurar, conectar y programar una pieza del stack, usando como ejemplo el código que hace funcionar este sitio.</p>
    <p class="suave">Esta misma página reúne tres fuentes. El HTML, la lista de pasos y los enlaces de abajo los genera CodeIgniter con datos de SQL Server. El grafo lo dibuja el navegador con JSON que pide a FastAPI con fetch. El estado de cada nodo viene de WildFly, también con fetch.</p>
</section>

<section aria-labelledby="t-grafo">
    <h2 id="t-grafo">Grafo</h2>
    <p class="ayuda">Cada nodo es una tecnología y cada flecha, lo que viaja entre dos de ellas. Pulsa un nodo o una etiqueta para ver el detalle. Línea continua: petición en ejecución. Discontinua: construcción y despliegue.</p>

    <div class="filtros" role="group" aria-label="Filtrar enlaces">
        <button type="button" data-filtro="todo" aria-pressed="true">Todo</button>
        <button type="button" data-filtro="ejecucion" aria-pressed="false">Ejecución</button>
        <button type="button" data-filtro="construccion" aria-pressed="false">Construcción</button>
        <button type="button" id="reverificar">Verificar servicios</button>
    </div>

    <div class="lienzo">
        <svg id="grafo" viewBox="10 70 920 520" role="img" aria-label="Grafo de tecnologías y sus enlaces"></svg>
        <aside id="detalle" aria-live="polite">
            <p class="suave">Selecciona un nodo o un enlace.</p>
        </aside>
    </div>
    <p id="origen-grafo" class="suave">Grafo: consultando FastAPI…</p>
    <p id="estado" class="suave">Estado: consultando WildFly…</p>
</section>

<section aria-labelledby="t-orden">
    <h2 id="t-orden">Orden de construcción</h2>
    <p class="ayuda">El orden recomendado para construir el proyecto desde cero. Cada paso depende de los anteriores.</p>
    <ol class="pasos-lista">
        <?php foreach ($tecnologias as $t): ?>
            <li>
                <a href="<?= base_url('tecnologia/' . $t['clave']) ?>"><?= esc($t['nombre']) ?></a>
                <span class="suave">· <?= esc($t['rol']) ?> · <?= esc($t['version'] ?? '') ?></span>
            </li>
        <?php endforeach ?>
    </ol>
</section>

<section aria-labelledby="t-enlaces">
    <h2 id="t-enlaces">Enlaces: qué viaja y cómo se transforma</h2>
    <p class="ayuda">La misma información que muestra el grafo, en texto. Funciona aunque FastAPI no responda.</p>
    <?php foreach ($enlaces as $e): ?>
        <details class="enlace-detalle" id="enlace-<?= esc($e['id'], 'attr') ?>">
            <summary>
                <span class="num"><?= esc($e['id']) ?></span>
                <?= esc($e['origen_nombre']) ?> → <?= esc($e['destino_nombre']) ?>
                <span class="suave">· <?= esc($e['etiqueta']) ?></span>
            </summary>
            <dl>
                <dt>Tipo</dt><dd><?= $e['tipo'] === 'ejecucion' ? 'Ejecución' : 'Construcción' ?></dd>
                <dt>Protocolo</dt><dd><?= esc($e['protocolo']) ?></dd>
                <dt>Ida</dt><dd><?= esc($e['dato_ida']) ?></dd>
                <dt>Vuelta</dt><dd><?= esc($e['dato_vuelta']) ?></dd>
                <dt>Transformación</dt><dd><?= esc($e['transformacion']) ?></dd>
            </dl>
        </details>
    <?php endforeach ?>
</section>

<section aria-labelledby="t-consola">
    <h2 id="t-consola">Consola fetch</h2>
    <p class="ayuda">Ejecuta desde el navegador las mismas peticiones que usa el sitio y observa la respuesta sin procesar.</p>
    <div class="consola-controles">
        <label for="endpoint">Endpoint</label>
        <select id="endpoint"></select>
        <button type="button" id="ejecutar">Ejecutar</button>
    </div>
    <pre class="codigo" data-lenguaje="javascript"><code id="consola-codigo"></code></pre>
    <pre class="salida" id="consola-salida" aria-live="polite">Elige un endpoint y pulsa Ejecutar.</pre>
</section>

<?= $this->endSection() ?>

<?= $this->section('scripts') ?>
<script src="<?= base_url('js/grafo.js') ?>" defer></script>
<script src="<?= base_url('js/consola.js') ?>" defer></script>
<?= $this->endSection() ?>
