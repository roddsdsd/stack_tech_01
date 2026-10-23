<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= esc($titulo) ?> · Stack tecnológico 02</title>
    <link rel="stylesheet" href="<?= base_url('css/estilo.css') ?>">
</head>
<body data-api="<?= esc($apiUrl, 'attr') ?>"
      data-monitor="<?= esc($monitorUrl, 'attr') ?>"
      data-base="<?= esc(base_url(), 'attr') ?>">

<header class="cabecera">
    <a class="marca" href="<?= base_url() ?>">Stack tecnológico 02</a>
    <nav aria-label="Tecnologías">
        <?php foreach ($menu as $item): ?>
            <a href="<?= base_url('tecnologia/' . $item['clave']) ?>"<?= $actual === $item['clave'] ? ' aria-current="page"' : '' ?>><?= esc($item['nombre']) ?></a>
        <?php endforeach ?>
    </nav>
</header>

<main>
    <?= $this->renderSection('contenido') ?>
</main>

<footer class="pie">
    HTML generado por CodeIgniter 4 con datos de SQL Server · grafo vía FastAPI · estado vía WildFly
</footer>

<?= $this->renderSection('scripts') ?>
</body>
</html>
