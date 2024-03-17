ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm


# RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
#            -e 's|security.debian.org|archive.debian.org/|g' \
#            -e '/stretch-updates/d' /etc/apt/sources.list

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libzip-dev\
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Install extensions
RUN docker-php-ext-configure gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install zip \
    && docker-php-ext-install gd \
    && docker-php-ext-enable zip \
    && docker-php-ext-enable gd\
    && docker-php-ext-enable pdo_mysql 

# first configure the to-be-installed extension
# RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr

# Only then install it
RUN docker-php-ext-install gd

RUN groupadd --gid 819 docker_user && \
    adduser  --uid 819 --home /var/cache/nginx --disabled-login --gid 819 docker_user

# Add docker alias for development
RUN echo 'alias ll="ls -al"' >> ~/.bashrc

# Update environment
RUN /bin/bash -c "source ~/.bashrc"

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set permissions
ARG VOLUME_PATH
RUN echo ${VOLUME_PATH}
RUN mkdir ${VOLUME_PATH}
RUN chown -R docker_user:docker_user ${VOLUME_PATH}

RUN composer require google/apiclient

# Change current user to root

USER root