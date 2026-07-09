FROM php:8.3-apache

# Install system dependencies and PHP extensions
RUN set -ex; \
    apt-get update; \
    apt-get install -y \
        unzip \
        git \
        openssl \
        libcurl4-openssl-dev \
        libjpeg-dev \
        libpng-dev \
        libxml2-dev \
        libonig-dev \
        libzip-dev \
        libicu-dev \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    docker-php-ext-configure gd --with-jpeg=/usr; \
    docker-php-ext-install -j$(nproc) pdo_mysql dom gd mbstring zip exif intl

# Install Redis extension
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Set recommended PHP.ini settings for production
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=0'; \
        echo 'opcache.validate_timestamps=0'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
        echo 'expose_php=Off'; \
        echo 'upload_max_filesize=32M'; \
        echo 'post_max_size=32M'; \
        echo 'memory_limit=256M'; \
    } > /usr/local/etc/php/conf.d/production.ini

# Enable Apache rewrite module
RUN a2enmod rewrite

# Configure Apache DocumentRoot to point to public directory
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|<Directory /var/www/>|<Directory /var/www/html/public>\n\tAllowOverride All|g' /etc/apache2/apache2.conf

# Set the working directory
WORKDIR /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clone TastyRhodos (your fork with customizations)
# Using specific branch to ensure reproducible builds
ARG TASTYRHODOS_BRANCH=4.x
# CACHEBUST invalidates the clone + composer layers WITHOUT rebuilding the slow
# apt/pecl base. Pass a changing value (e.g. --build-arg CACHEBUST=$(date +%s))
# on every deploy so a rebuild always fetches the latest fork commit instead of
# reusing Docker's cached (stale) clone.
ARG CACHEBUST=1
RUN echo "cachebust=${CACHEBUST}" && git clone --depth 1 --branch ${TASTYRHODOS_BRANCH} \
    https://github.com/iamnothardcoded/tastyrhodos.git /usr/src/tastyigniter

# Copy .htaccess with Authorization header fix
COPY .htaccess /usr/src/tastyigniter/

# Install Composer dependencies
RUN cd /usr/src/tastyigniter && \
    composer install --no-dev --optimize-autoloader --no-interaction

# Staff-pos is cloned as part of the repo structure or mounted separately
# No separate COPY needed - it will be in the tastyrhodos repo if committed there

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set proper ownership
RUN chown -R www-data:www-data /usr/src/tastyigniter

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
