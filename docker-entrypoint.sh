#!/bin/bash
set -e

# =============================================================================
# TastyIgniter Docker Entrypoint
# =============================================================================
# This script handles first-time setup and ensures safe container restarts.
#
# SAFETY: We NEVER run igniter:install automatically to prevent accidental
# database overwrites. First-time setup must be done manually.
#
# CLOBBER-PROOF (2026-07-16): bind mounts under /var/www/html are detected
# from /proc/mounts and EXCLUDED from both the first-run copy and the chown.
# A container recreate can therefore never overwrite mounted host files
# (the "jamasa clobber trap") — regardless of how stale the image is, and
# for any mount, present or future. Environments without mounts (tenants)
# get the full copy exactly as before.
# =============================================================================

# Copy application files if not present (first run or empty volume)
if [ ! -e '/var/www/html/artisan' ]; then
    echo "📦 First run detected - copying application files..."

    # Detect mounts inside the app dir. NON-EMPTY mounts (bind-mounted source
    # code, existing volumes) are excluded — never overwrite them. EMPTY mounts
    # (fresh named volumes, e.g. storage on a new tenant) stay in the copy so
    # they get their initial content exactly as before.
    EXCLUDES=()
    while IFS= read -r mnt; do
        rel="${mnt#/var/www/html/}"
        if [ -n "$rel" ] && [ "$rel" != "$mnt" ]; then
            if [ -n "$(ls -A "$mnt" 2>/dev/null)" ]; then
                EXCLUDES+=("--exclude=./$rel")
                echo "   ⛔ populated mount, not copying over: $rel"
            else
                echo "   📥 empty mount, will receive initial content: $rel"
            fi
        fi
    done < <(awk '$2 ~ /^\/var\/www\/html\// {print $2}' /proc/mounts)

    tar cf - --one-file-system -C /usr/src/tastyigniter "${EXCLUDES[@]}" . | tar xf -

    # chown without crossing filesystem boundaries: -xdev keeps bind-mounted
    # host files under their host ownership (no more EACCES after recreate)
    find /var/www/html -xdev -exec chown www-data:www-data {} +

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

# Clear compiled files that might be stale + republish theme assets
# (public/ is image-layer, so published fonts/FA vanish on every recreate —
# republishing here makes that self-healing; igniter-assets covers the
# famedo theme's assets/ dir → public/vendor/famedo)
if [ -e '/var/www/html/artisan' ]; then
    php artisan view:clear 2>/dev/null || true
    php artisan config:clear 2>/dev/null || true
    php artisan vendor:publish --tag=igniter-assets --force 2>/dev/null || true
    rm -rf /var/www/html/public/vendor/jamasa 2>/dev/null || true
fi

echo "🚀 Starting Apache..."
exec "$@"
