<?php

namespace App\Controllers;

use CodeIgniter\HTTP\ResponseInterface;

/** GET /salud: JSON que consulta WildFly. Incluye una comprobación de SQL Server. */
class Salud extends BaseController
{
    public function index(): ResponseInterface
    {
        $inicio = microtime(true);

        try {
            $fila = db_connect()->query('SELECT COUNT(*) AS total FROM tecnologias')->getRowArray();
            $bd   = ['ok' => true, 'tecnologias' => (int) $fila['total']];
        } catch (\Throwable $e) {
            $bd = ['ok' => false, 'error' => $e->getMessage()];
        }

        return $this->response
            ->setStatusCode($bd['ok'] ? 200 : 503)
            ->setJSON([
                'servicio'     => 'codeigniter4',
                'ok'           => $bd['ok'],
                'bd'           => $bd,
                'milisegundos' => (int) round((microtime(true) - $inicio) * 1000),
            ]);
    }
}
