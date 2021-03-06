FROM php:7.4-cli-alpine

RUN apk upgrade --no-cache \
 && apk add --no-cache libzip-dev libpng-dev git \
 && docker-php-ext-install zip gd

COPY grav /var/www/grav
COPY files/bin /var/www/grav/bin
COPY files/php/php.ini /usr/local/etc/php/php.ini
WORKDIR /var/www/grav
ENV HOME /var/www/grav
ENV STG_PLUGIN_INSTALL false

RUN adduser -S -G www-data grav \
 && chown -R grav:www-data /var/www/grav /usr/local/etc/php/php.ini \
 && find /var/www/grav -type d -exec chmod 755 {} + \
 && find /var/www/grav -type f -exec chmod 664 {} + \
 && chmod +x /var/www/grav/bin/*

USER grav

RUN php bin/composer.phar install --no-dev -o \ 
 && rm -fR /home/grav/.composer \
 && sh user/plugins/production.sh

EXPOSE 8080
CMD [ "/var/www/grav/bin/run.sh" ]