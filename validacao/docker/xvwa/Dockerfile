FROM php:7.4-apache

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        git iputils-ping default-mysql-client ca-certificates \
 && docker-php-ext-install mysqli pdo pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/s4n7h0/xvwa.git /var/www/html/xvwa

COPY config.php /var/www/html/xvwa/config.php

RUN { \
      echo 'file_uploads = On'; \
      echo 'allow_url_fopen = On'; \
      echo 'allow_url_include = On'; \
      echo 'display_errors = On'; \
    } > /usr/local/etc/php/conf.d/xvwa.ini \
 && chown -R www-data:www-data /var/www/html/xvwa
