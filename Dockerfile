FROM alpine:latest
LABEL maintainer="FAN VINGA<fanalcest@gmail.com> ZE3kr<ze3kr@icloud.com>"

ENV HOST_KEY=e9e4498f0584b7098692512db0c62b48 \
    HOST_MAIL=ze3kr@example.com \
    TITLE=CFPANEL

WORKDIR /app
COPY composer.json /app/composer.json
RUN apk --no-cache --virtual runtimes add curl \
    nginx \
    php7 \
    php7-fpm \
    php7-cli \
    php7-json \
    php7-gettext \
    php7-curl \
    php7-apcu \
    php7-phar \
    php7-iconv \
    php7-mbstring \
    php7-openssl
RUN cd /app && curl -s https://getcomposer.org/installer | php && \
    php composer.phar install --no-dev -o

COPY . /app
RUN rm /etc/nginx/conf.d/default.conf && \
    cp /app/.docker/nginx.conf /etc/nginx/conf.d/cloudflare.conf && \
    cp /app/.docker/php-fpm.conf /etc/php7/php-fpm.conf && \
    cp /app/config.example.php /app/config.php

EXPOSE 8080

CMD sed -i "s|e9e4498f0584b7098692512db0c62b48|${HOST_KEY}|g" /app/config.php && \
    sed -i "s|ze3kr@example.com|${HOST_MAIL}|g" /app/config.php && \
    sed -i "s|// \$page_title = \"TlOxygen\"|\$page_title = \"${TITLE}\"|g" /app/config.php && \
    sed -i "s|// \$tlo_path = \"/\"|\$tlo_path = \"/\"|g" /app/config.php && \
    mkdir -p /run/nginx && nginx && \
    php-fpm7 --nodaemonize --fpm-config /etc/php7/php-fpm.conf -c /etc/php7/php.ini
