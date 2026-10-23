<?php

namespace App\Models;

use CodeIgniter\Model;

/** Tabla archivos: rutas del repositorio que se muestran en cada página. */
class ArchivoModel extends Model
{
    protected $table      = 'archivos';
    protected $returnType = 'array';

    public function deTecnologia(int $id): array
    {
        return $this->where('tecnologia_id', $id)->orderBy('orden')->findAll();
    }
}
