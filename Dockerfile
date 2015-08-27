# Pull base image (either ARM based for Raspberry Pi or x86 based for regular image)

# FROM debian:jessie
FROM resin/rpi-raspbian:jessie

MAINTAINER Mathias Hansen <me@codemonkey.io>

#
# PHP & PHP-FPM
#

# persistent / runtime deps
RUN apt-get update && apt-get install -y ca-certificates curl libpcre3 librecode0 libsqlite3-0 libxml2 --no-install-recommends && rm -r /var/lib/apt/lists/*

# phpize deps
RUN apt-get update && apt-get install -y autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends && rm -r /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

##<autogenerated>##
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data
##</autogenerated>##

ENV GPG_KEYS 0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3
RUN set -xe \
  && for key in $GPG_KEYS; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV PHP_VERSION 5.6.12

# --enable-mysqlnd is included below because it's harder to compile after the fact the extensions are (since it's a plugin for several extensions, not an extension in itself)
RUN buildDeps=" \
    $PHP_EXTRA_BUILD_DEPS \
    libcurl4-openssl-dev \
    libpcre3-dev \
    libreadline6-dev \
    librecode-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    xz-utils \
  " \
  && set -x \
  && apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
  && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror" -o php.tar.xz \
  && curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz.asc/from/this/mirror" -o php.tar.xz.asc \
  && gpg --verify php.tar.xz.asc \
  && mkdir -p /usr/src/php \
  && tar -xof php.tar.xz -C /usr/src/php --strip-components=1 \
  && rm php.tar.xz* \
  && cd /usr/src/php \
  && ./configure \
    --with-config-file-path="$PHP_INI_DIR" \
    --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
    $PHP_EXTRA_CONFIGURE_ARGS \
    --disable-cgi \
    --enable-mysqlnd \
    --with-curl \
    --with-openssl \
    --with-pcre \
    --with-readline \
    --with-recode \
    --with-zlib \
  && make -j"$(nproc)" \
  && make install \
  && { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
  && make clean

COPY docker-php-ext-* /usr/local/bin/

WORKDIR /var/www/
COPY php-fpm.conf /usr/local/etc/
RUN mkdir -p /var/run/php5-fpm && chown -R www-data:www-data /var/run/php5-fpm
COPY php-extra.ini /usr/local/etc/php/conf.d/

#
# Additional packages
#
RUN apt-get update && apt-get install -y nginx supervisor git --no-install-recommends && rm -r /var/lib/apt/lists/*
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install sockets

#
# hjem source code
#
RUN rm -rf /var/www/html && \
  git clone https://github.com/hjem/hjem.git /var/www/hjem && \
  cd /var/www/hjem && \
  composer install -o --no-dev --prefer-source --no-interaction && \
  touch storage/database.sqlite && \
  chmod -R 777 storage && \
  chmod -R 777 bootstrap

#
# nginx
#
RUN rm /etc/nginx/sites-available/default
COPY nginx-default /etc/nginx/sites-available/default

#
# supervisor
#

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]
