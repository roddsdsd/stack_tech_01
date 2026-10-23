# Se construye con la raíz del repositorio como contexto (ver docker-compose.yml)

# Etapa 1 · Composer: proyecto base de CodeIgniter 4
FROM composer:2 AS base
WORKDIR /app
RUN composer create-project codeigniter4/appstarter:^4.6 . \
    --no-dev --no-interaction --prefer-dist --ignore-platform-reqs

# Etapa 2 · PHP + Apache + driver de SQL Server
FROM php:8.3-apache-bookworm

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates libicu-dev unixodbc-dev \
 && curl -fsSL -o /tmp/ms.deb https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
 && dpkg -i /tmp/ms.deb && rm /tmp/ms.deb \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
 && docker-php-ext-install intl \
 && pecl install sqlsrv-5.12.0 \
 && docker-php-ext-enable sqlsrv \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/* /tmp/pear

COPY codeigniter/apache.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/app
COPY --from=base /app ./
# Nuestra aplicación se copia encima del proyecto base
COPY codeigniter/app/ ./app/
COPY codeigniter/public/ ./public/
RUN chown -R www-data:www-data writable

# El repositorio completo, para mostrar sus archivos en la documentación
COPY . /proyecto

EXPOSE 80
