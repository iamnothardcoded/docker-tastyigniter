#!/bin/bash
set -e

# =============================================================================
# TastyIgniter Docker Entrypoint
# =============================================================================
# This script handles first-time setup and ensures safe container restarts.
#
# SAFETY: We NEVER run igniter:install automatically to prevent accidental
# database overwrites. First-time setup must be done manually.
# =============================================================================

# Copy application files if not present (first run or empty volume)
if [ ! -e '/var/www/html/artisan' ]; then
    echo "📦 First run detected - copying application files..."
    tar cf - --one-file-system -C /usr/src/tastyigniter . | tar xf -
    chown -R www-data:www-data /var/www/html

    # Create .env from example if needed
    if [ -e '.env.example' ] && [ ! -e '.env' ]; then
        cp .env.example .env
        echo "📝 Created .env from .env.example"
    fi

    # Generate app key if not set
    if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
        php artisan key:generate --force
        echo "🔑 Generated application key"
    fi

    echo ""
    echo "=============================================="
    echo "⚠️  FIRST-TIME SETUP REQUIRED"
    echo "=============================================="
    echo ""
    echo "Run this command to complete installation:"
    echo ""
    echo "  docker compose exec app php artisan igniter:install"
    echo ""
    echo "This is intentionally NOT automatic to prevent"
    echo "accidental database overwrites on container restart."
    echo "=============================================="
    echo ""
fi

# Ensure storage directories are writable
if [ -d '/var/www/html/storage' ]; then
    chown -R www-data:www-data /var/www/html/storage 2>/dev/null || true
fi

# Clear compiled files that might be stale
if [ -e '/var/www/html/artisan' ]; then
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
fi

echo "🚀 Starting Apache..."
exec "$@"
