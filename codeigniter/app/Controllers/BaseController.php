<?php

namespace App\Controllers;

use App\Models\TecnologiaModel;
use CodeIgniter\Controller;

/**
 * Base de todos los controladores: carga el helper de texto y
 * añade a cada página los datos que usa la plantilla común.
 */
abstract class BaseController extends Controller
{
    protected $helpers = ['texto'];

    protected function pagina(string $vista, array $datos): string
    {
        $datos += [
            'menu'       => (new TecnologiaModel())->ordenadas(),
            'actual'     => null,
            // URLs públicas (las que ve el navegador), no los nombres internos de Docker
            'apiUrl'     => rtrim(getenv('PUBLIC_API_URL') ?: 'http://localhost:8000', '/'),
            'monitorUrl' => rtrim(getenv('PUBLIC_MONITOR_URL') ?: 'http://localhost:8081/monitor', '/'),
        ];

        return view($vista, $datos);
    }
}
