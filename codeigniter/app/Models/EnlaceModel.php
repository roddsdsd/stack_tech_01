<?php

namespace App\Models;

use CodeIgniter\Model;

/** Vista v_enlaces: enlaces con las claves y nombres de origen y destino. */
class EnlaceModel extends Model
{
    protected $table      = 'v_enlaces';
    protected $returnType = 'array';

    public function todos(): array
    {
        return $this->orderBy('id')->findAll();
    }

    public function deTecnologia(int $id): array
    {
        return $this->groupStart()
            ->where('origen_id', $id)
            ->orWhere('destino_id', $id)
            ->groupEnd()
            ->orderBy('id')
            ->findAll();
    }
}
