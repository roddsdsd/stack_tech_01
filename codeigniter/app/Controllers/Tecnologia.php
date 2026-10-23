<?php

namespace App\Controllers;

use App\Models\ArchivoModel;
use App\Models\EnlaceModel;
use App\Models\SeccionModel;
use App\Models\TecnologiaModel;
use CodeIgniter\Exceptions\PageNotFoundException;

/** Página de documentación de una tecnología: /tecnologia/{clave} */
class Tecnologia extends BaseController
{
    private const LIMITE_BYTES = 200_000;

    public function ver(string $clave): string
    {
        $modelo     = new TecnologiaModel();
        $tecnologia = $modelo->porClave($clave);

        if ($tecnologia === null) {
            throw PageNotFoundException::forPageNotFound("No existe la tecnología «{$clave}».");
        }

        $id      = (int) $tecnologia['id'];
        $orden   = (int) $tecnologia['orden'];
        $enlaces = (new EnlaceModel())->deTecnologia($id);
        $menu    = $modelo->ordenadas();

        return $this->pagina('tecnologia', [
            'titulo'     => $tecnologia['nombre'],
            'menu'       => $menu,
            'actual'     => $clave,
            'total'      => count($menu),
            'tecnologia' => $tecnologia,
            'secciones'  => (new SeccionModel())->deTecnologia($id),
            'salientes'  => array_filter($enlaces, static fn ($e) => (int) $e['origen_id'] === $id),
            'entrantes'  => array_filter($enlaces, static fn ($e) => (int) $e['destino_id'] === $id),
            'archivos'   => $this->leerArchivos((new ArchivoModel())->deTecnologia($id)),
            'anterior'   => $modelo->porOrden($orden - 1),
            'siguiente'  => $modelo->porOrden($orden + 1),
        ]);
    }

    /**
     * Añade el contenido de cada archivo registrado en la tabla `archivos`.
     * Solo se leen rutas que, ya resueltas, quedan dentro del repositorio.
     */
    private function leerArchivos(array $archivos): array
    {
        $base = realpath(getenv('PROYECTO_DIR') ?: '/proyecto');

        foreach ($archivos as &$archivo) {
            $ruta = $base === false ? false : realpath($base . DIRECTORY_SEPARATOR . $archivo['ruta']);
            $dentro = $ruta !== false && str_starts_with($ruta, $base . DIRECTORY_SEPARATOR) && is_file($ruta);

            $archivo['contenido'] = $dentro && filesize($ruta) <= self::LIMITE_BYTES
                ? file_get_contents($ruta)
                : null;
        }

        return $archivos;
    }
}
