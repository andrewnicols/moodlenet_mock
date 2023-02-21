FROM php:8.2-apache

LABEL maintainer="Andrew Lyons <andrew@nicols.co.uk>" \
    org.opencontainers.image.source="https://github.com/andrewnicols/moodlenet_mock"

ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN echo "Building for ${TARGETPLATFORM}"

EXPOSE 80
EXPOSE 443

RUN apt-get update \
    && apt-get install -y zlib1g-dev g++ git libicu-dev zip libzip-dev gnupg apt-transport-https \
    && curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
    && apt-get update \
    && apt-get install -y symfony-cli \
    && apt-get purge -y --auto-remove -o APT:::AutoRemove::RecommendsImportant=false

WORKDIR /var/www

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN symfony check:requirements

COPY docker/entrypoint.sh /entrypoint.sh
COPY application /var/www
COPY certs /opt/certs

RUN composer install -n \
    && rm -rf /root/.composer

CMD ["symfony", "server:start", "--no-tls", "--p12=/opt/certs/certs/moodlenet_mock.p12"]
ENTRYPOINT ["/entrypoint.sh"]
