<?= $this->extend('plantilla') ?>

<?= $this->section('contenido') ?>

<article class="doc">
    <p class="miga">
        <a href="<?= base_url() ?>">Grafo</a> / Paso <?= esc($tecnologia['orden']) ?> de <?= esc($total) ?>
    </p>

    <h1><?= esc($tecnologia['nombre']) ?></h1>

    <dl class="ficha">
        <dt>Rol</dt><dd><?= esc($tecnologia['rol']) ?></dd>
        <dt>Capa</dt><dd><?= esc($tecnologia['capa']) ?></dd>
        <?php if ($tecnologia['version']): ?><dt>Versión</dt><dd><?= esc($tecnologia['version']) ?></dd><?php endif ?>
        <?php if ($tecnologia['puerto']): ?><dt>Puerto</dt><dd><?= esc($tecnologia['puerto']) ?></dd><?php endif ?>
    </dl>

    <p class="lead"><?= esc($tecnologia['descripcion']) ?></p>

    <nav class="indice" aria-label="En esta página">
        <strong>En esta página</strong>
        <ol>
            <?php foreach ($secciones as $s): ?>
                <?php if ($s['titulo']): ?>
                    <li><a href="#s<?= esc($s['id'], 'attr') ?>"><?= esc($s['titulo']) ?></a></li>
                <?php endif ?>
            <?php endforeach ?>
            <li><a href="#conexiones">Conexiones</a></li>
            <li><a href="#archivos">Archivos del proyecto</a></li>
        </ol>
    </nav>

    <?php foreach ($secciones as $s): ?>
        <?php if ($s['titulo']): ?>
            <h2 id="s<?= esc($s['id'], 'attr') ?>"><?= esc($s['titulo']) ?></h2>
        <?php endif ?>
        <?= bloque($s) ?>
    <?php endforeach ?>

    <h2 id="conexiones">Conexiones</h2>
    <?php foreach (['Salientes' => $salientes, 'Entrantes' => $entrantes] as $grupo => $lista): ?>
        <?php if ($lista !== []): ?>
            <h3><?= $grupo ?></h3>
            <?php foreach ($lista as $e): ?>
                <details class="enlace-detalle">
                    <summary>
                        <span class="num"><?= esc($e['id']) ?></span>
                        <?= esc($e['origen_nombre']) ?> → <?= esc($e['destino_nombre']) ?>
                        <span class="suave">· <?= esc($e['etiqueta']) ?></span>
                    </summary>
                    <dl>
                        <dt>Protocolo</dt><dd><?= esc($e['protocolo']) ?></dd>
                        <dt>Ida</dt><dd><?= esc($e['dato_ida']) ?></dd>
                        <dt>Vuelta</dt><dd><?= esc($e['dato_vuelta']) ?></dd>
                        <dt>Transformación</dt><dd><?= esc($e['transformacion']) ?></dd>
                    </dl>
                </details>
            <?php endforeach ?>
        <?php endif ?>
    <?php endforeach ?>

    <h2 id="archivos">Archivos del proyecto</h2>
    <p class="ayuda">Leídos del repositorio en el momento de generar esta página.</p>
    <?php foreach ($archivos as $a): ?>
        <details class="archivo">
            <summary><code><?= esc($a['ruta']) ?></code> <span class="suave">· <?= esc($a['descripcion']) ?></span></summary>
            <?php if ($a['contenido'] === null): ?>
                <p class="nota">No se pudo leer el archivo.</p>
            <?php else: ?>
                <pre class="codigo"><code><?= esc($a['contenido']) ?></code></pre>
            <?php endif ?>
        </details>
    <?php endforeach ?>

    <nav class="pasos" aria-label="Pasos">
        <?php if ($anterior): ?>
            <a href="<?= base_url('tecnologia/' . $anterior['clave']) ?>">← <?= esc($anterior['nombre']) ?></a>
        <?php else: ?><span></span><?php endif ?>
        <?php if ($siguiente): ?>
            <a href="<?= base_url('tecnologia/' . $siguiente['clave']) ?>"><?= esc($siguiente['nombre']) ?> →</a>
        <?php endif ?>
    </nav>
</article>

<?= $this->endSection() ?>
