<?php

namespace App\Models;

use CodeIgniter\Model;

/** Tabla secciones: bloques de documentación. */
class SeccionModel extends Model
{
    protected $table      = 'secciones';
    protected $returnType = 'array';

    public function deTecnologia(int $id): array
    {
        return $this->where('tecnologia_id', $id)->orderBy('orden')->findAll();
    }
}
