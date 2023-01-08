## PHP-FPM
FROM php:fpm-alpine AS php_fpm

RUN set -eux; \
	apk add --no-cache --virtual .build-deps $PHPIZE_DEPS icu-dev libzip-dev zlib-dev; \
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) intl zip; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .phpexts-rundeps $runDeps; \
	apk del .build-deps

RUN ln -s $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY .docker/php-fpm/conf.d/php.prod.ini $PHP_INI_DIR/conf.d/php.prod.ini
COPY .docker/php-fpm/php-fpm.d/php-fpm.conf /usr/local/etc/php-fpm.d/php-fpm.conf

WORKDIR /srv/app

CMD ["php-fpm"]

## Symfony
FROM composer:latest AS symfony

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /srv/app

RUN composer create-project "symfony/skeleton" . --stability=stable --prefer-dist --no-dev --no-progress --no-interaction; \
	composer clear-cache

RUN set -eux; \
	mkdir -p var/cache var/log; \
    composer require doctrine/annotations; \
	composer install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction; \
	composer dump-autoload --classmap-authoritative --no-dev; \
	composer symfony:dump-env prod; \
	composer run-script --no-dev post-install-cmd; \
	chmod +x bin/console; sync

CMD ["tail", "-f", "/dev/null"]

## Nginx
FROM nginx as nginx
COPY .docker/nginx/conf.d/nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /srv/app/public
CMD ["nginx", "-g", "daemon off;"]

## Caddy
FROM caddy as caddy
COPY .docker/caddy/Caddyfile /etc/caddy/Caddyfile
WORKDIR /srv/app/public
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]

## h2load
FROM ubuntu as h2load
RUN apt-get update
RUN apt-get -y install nghttp2-client
