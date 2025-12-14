#!/bin/bash
set -e

# Check if the index.php file exists
if [ ! -e '/var/www/html/index.php' ]; then
    # Extract TastyIgniter and set up
    tar cf - --one-file-system -C /usr/src/tastyigniter . | tar xf -
    chown -R www-data:www-data /var/www/html

    # Create .env file from .env.example if it exists
    if [ -e '.env.example' ] && [ ! -e '.env' ]; then
        cp .env.example .env
    fi

    # Generate application key and run the setup
    php artisan key:generate --force
    php artisan igniter:install --no-interaction
fi

# Execute the provided command (Apache in this case)
exec "$@"
