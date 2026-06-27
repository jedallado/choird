# syntax=docker/dockerfile:1

FROM php:8.3-cli-bookworm AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    curl \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    default-libmysqlclient-dev \
    && docker-php-ext-install -j"$(nproc)" \
        intl \
        zip \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        bcmath \
        pcntl \
        opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_NO_INTERACTION=1

FROM base AS vendor

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-scripts --no-autoloader

COPY . .
RUN composer install --no-dev --prefer-dist --optimize-autoloader

FROM node:20-bookworm AS assets

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY vite.config.js ./
COPY resources ./resources
COPY public ./public

RUN npm run build

FROM base AS runtime

WORKDIR /app

COPY --from=vendor /app /app
COPY --from=assets /app/public/build ./public/build

RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R ug+rwx storage bootstrap/cache

COPY railway/init-app.sh railway/run-worker.sh railway/start.sh ./railway/
RUN chmod +x railway/init-app.sh railway/run-worker.sh railway/start.sh

USER www-data

EXPOSE 8080

CMD ["./railway/start.sh"]
