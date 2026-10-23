<?php

namespace App\Controllers;

use App\Models\EnlaceModel;
use App\Models\TecnologiaModel;

/** Portada: grafo (lo dibuja el navegador), orden de construcción y tabla de enlaces. */
class Inicio extends BaseController
{
    public function index(): string
    {
        $tecnologias = (new TecnologiaModel())->ordenadas();

        return $this->pagina('inicio', [
            'titulo'      => 'Grafo del stack',
            'menu'        => $tecnologias,
            'tecnologias' => $tecnologias,
            'enlaces'     => (new EnlaceModel())->todos(),
        ]);
    }
}
