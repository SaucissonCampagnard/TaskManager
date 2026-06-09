FROM php:8.4-apache

# Dépendances système + extensions PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libicu-dev \
    libzip-dev \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        intl \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Apache modules nécessaires (Symfony)
RUN a2enmod rewrite headers

# Répertoire de travail
WORKDIR /var/www/html

# Copie du projet
COPY . .

# Permissions (important sinon Symfony casse souvent)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Installation des dépendances PHP en prod
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Variables d'environnement Symfony
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Apache pointe vers /public (OBLIGATOIRE pour Symfony)
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Cache Symfony (optionnel mais propre en prod)
RUN php bin/console cache:clear --env=prod || true
RUN php bin/console cache:warmup --env=prod || true

EXPOSE 80