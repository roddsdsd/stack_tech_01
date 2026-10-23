<?php

namespace App\Models;

use CodeIgniter\Model;

/** Tabla tecnologias: los nodos del grafo. */
class TecnologiaModel extends Model
{
    protected $table      = 'tecnologias';
    protected $returnType = 'array';

    public function ordenadas(): array
    {
        return $this->orderBy('orden')->findAll();
    }

    public function porClave(string $clave): ?array
    {
        return $this->where('clave', $clave)->first();
    }

    public function porOrden(int $orden): ?array
    {
        return $this->where('orden', $orden)->first();
    }
}
