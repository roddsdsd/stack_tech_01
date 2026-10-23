<?php

/**
 * Convierte el texto de la tabla `secciones` en HTML.
 * Formato mínimo: párrafos separados por línea en blanco,
 * listas con líneas que empiezan por "- " y `código` entre comillas invertidas.
 * Todo se escapa con esc() antes de añadir etiquetas.
 */

if (! function_exists('en_linea')) {
    function en_linea(string $texto): string
    {
        return preg_replace('/`([^`]+)`/', '<code>$1</code>', esc($texto));
    }
}

if (! function_exists('texto_a_html')) {
    function texto_a_html(string $texto): string
    {
        $html = '';

        foreach (preg_split('/\n\s*\n/', trim(str_replace("\r\n", "\n", $texto))) as $bloque) {
            $lineas = explode("\n", $bloque);
            $lista  = array_filter($lineas, static fn ($l) => str_starts_with(ltrim($l), '- '));

            if (count($lista) === count($lineas)) {
                $items = array_map(static fn ($l) => '<li>' . en_linea(substr(ltrim($l), 2)) . '</li>', $lineas);
                $html .= '<ul>' . implode('', $items) . '</ul>';
            } else {
                $html .= '<p>' . en_linea($bloque) . '</p>';
            }
        }

        return $html;
    }
}

if (! function_exists('bloque')) {
    function bloque(array $seccion): string
    {
        $contenido = str_replace("\r\n", "\n", $seccion['contenido']);

        return match ($seccion['tipo']) {
            'comando', 'codigo' => '<pre class="' . $seccion['tipo'] . '" data-lenguaje="'
                . esc($seccion['lenguaje'] ?? '', 'attr') . '"><code>' . esc($contenido) . '</code></pre>',
            'nota'  => '<div class="nota">' . texto_a_html($contenido) . '</div>',
            default => texto_a_html($contenido),
        };
    }
}
