<?php

use CodeIgniter\Router\RouteCollection;

/**
 * Rutas: cada URL apunta a Controlador::método.
 *
 * @var RouteCollection $routes
 */
$routes->get('/', 'Inicio::index');
$routes->get('tecnologia/(:segment)', 'Tecnologia::ver/$1');
$routes->get('salud', 'Salud::index');
