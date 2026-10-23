<?php

namespace Config;

use CodeIgniter\Database\Config;

/**
 * Conexión a SQL Server con el driver SQLSRV (extensión sqlsrv de PHP).
 * Los valores reales llegan por variables de entorno (docker-compose.yml).
 */
class Database extends Config
{
    public string $filesPath = APPPATH . 'Database' . DIRECTORY_SEPARATOR;

    public string $defaultGroup = 'default';

    public array $default = [
        'DSN'      => '',
        'hostname' => 'localhost',
        'username' => 'stack_app',
        'password' => '',
        'database' => 'stack02',
        'schema'   => 'dbo',
        'DBDriver' => 'SQLSRV',
        'DBPrefix' => '',
        'pConnect' => false,
        'DBDebug'  => true,      // errores de SQL como excepciones
        'charset'  => 'utf8',    // CharacterSet UTF-8 en sqlsrv
        'swapPre'  => '',
        'encrypt'  => false,
        'failover' => [],
        'port'     => 1433,
    ];

    public function __construct()
    {
        parent::__construct();

        $this->default['hostname'] = getenv('DB_HOST') ?: $this->default['hostname'];
        $this->default['port']     = (int) (getenv('DB_PORT') ?: $this->default['port']);
        $this->default['database'] = getenv('DB_NAME') ?: $this->default['database'];
        $this->default['username'] = getenv('DB_USER') ?: $this->default['username'];
        $this->default['password'] = getenv('DB_PASSWORD') ?: $this->default['password'];
    }
}
