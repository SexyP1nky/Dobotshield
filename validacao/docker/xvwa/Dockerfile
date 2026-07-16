FROM php:7.4-apache@sha256:c9d7e608f73832673479770d66aacc8100011ec751d1905ff63fae3fe2e0ca6d

ARG XVWA_COMMIT=fb30fa517d288e618b521d252f61107ef6a24797

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        git iputils-ping default-mysql-client ca-certificates \
 && docker-php-ext-install mysqli pdo pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

RUN git init /var/www/html/xvwa \
 && git -C /var/www/html/xvwa remote add origin https://github.com/s4n7h0/xvwa.git \
 && git -C /var/www/html/xvwa fetch --depth 1 origin "$XVWA_COMMIT" \
 && git -C /var/www/html/xvwa checkout --detach FETCH_HEAD

COPY config.php /var/www/html/xvwa/config.php

RUN { \
      echo 'file_uploads = On'; \
      echo 'allow_url_fopen = On'; \
      echo 'allow_url_include = On'; \
      echo 'display_errors = On'; \
    } > /usr/local/etc/php/conf.d/xvwa.ini \
 && chown -R www-data:www-data /var/www/html/xvwa
