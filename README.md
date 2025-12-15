# Docker TastyIgniter

  Docker setup for [TastyIgniter](https://tastyigniter.com/) - a restaurant online ordering and management system.

  **Latest Versions:** TastyIgniter 4.0.4 • PHP 8.3 • MariaDB 10.7 • Redis 6

  ## ⚠️ Important: Multi-Container Application

  TastyIgniter requires **3 containers** to run:
  - Application (TastyIgniter + PHP + Apache)
  - Database (MariaDB)
  - Cache (Redis)

  **You cannot simply pull and run a single image.** Use the provided `docker-compose.yml` to orchestrate all services.

  ---

  ## Deployment Options

  ### Option 1: Quick Start (Docker Hub - Recommended)

  Pull pre-built image from Docker Hub:

  ```bash
  mkdir tastyigniter && cd tastyigniter
  curl -LO https://github.com/iamnothardcoded/tastyigniter-docker/raw/master/docker-compose.yml
  docker compose up -d
  ```

  Visit http://localhost:8080 and follow the setup wizard.

  For Synology DiskStation:
  1. Open Container Manager (formerly Docker)
  2. Go to Project → Create
  3. Name it "tastyigniter"
  4. Download https://github.com/iamnothardcoded/tastyigniter-docker/raw/master/docker-compose.yml and paste contents
  5. Click Create

  Option 2: Build from Source

  For developers who want to build locally:

  git clone https://github.com/iamnothardcoded/tastyigniter-docker.git
  cd tastyigniter-docker
  docker compose -f docker-compose.dev.yml up -d

  ---
  What's Included

  - TastyIgniter v4.0.4 - Latest stable release
  - PHP 8.3 with Apache
  - MariaDB 10.7 - Database server
  - Redis 6 - Caching layer
  - Auto-setup - Runs install on first launch

  Requirements

  - Docker 20.10+
  - Docker Compose 2.0+ (or 1.29+)
  - 2GB free RAM
  - 5GB free disk space

  Services

  | Service | Port | Description                |
  |---------|------|----------------------------|
  | app     | 8080 | TastyIgniter web interface |
  | db      | 3306 | MariaDB database           |
  | redis   | -    | Cache backend (internal)   |

  First Run Setup

  1. Start containers (see deployment options above)
  2. Wait 30-60 seconds for database initialization
  3. Visit http://localhost:8080/setup
  4. Follow the TastyIgniter setup wizard
  5. Use these database credentials:
    - Host: db
    - Database: tastyigniter
    - Username: tastyigniter
    - Password: somepassword

  Configuration

  Change Port

  Edit docker-compose.yml:
  ports:
    - "8080:80"  # Change 8080 to your preferred port

  Change Database Password

  Edit docker-compose.yml and update both places:
  # In app service:
  - DB_PASSWORD=your_new_password

  # In db service:
  - MYSQL_PASSWORD=your_new_password

  Custom Domain

  environment:
    - APP_URL=https://yourdomain.com

  Usage

  View Logs

  docker compose logs -f app

  Stop Services

  docker compose down

  Restart

  docker compose restart

  Complete Reset

  docker compose down -v  # Removes all data!

  Development

  For local development with live code editing:

  1. Clone this repository
  2. Use docker-compose.dev.yml which mounts your local app folder
  3. Edit files in /app directory
  4. Changes reflect immediately

  docker compose -f docker-compose.dev.yml up -d

  Clear cache after template changes:
  docker compose exec app php artisan cache:clear

  Project Structure

  tastyigniter-docker/
  ├── docker-compose.yml       # Production (Docker Hub image)
  ├── docker-compose.dev.yml   # Development (local build)
  ├── Dockerfile.dev           # PHP 8.3 + Apache image
  ├── docker-entrypoint.sh     # Auto-setup script
  └── .htaccess                # Apache rewrite rules

  Troubleshooting

  Port already in use

  Change port in docker-compose.yml:
  ports:
    - "8081:80"  # Use 8081 instead

  Database connection failed

  Wait longer for database initialization (can take 60 seconds on first run):
  docker compose logs db  # Check database logs

  Permission errors

  docker compose exec app chown -R www-data:www-data /var/www/html

  Start fresh

  docker compose down -v
  docker compose up -d

  Production Deployment

  For production use:

  1. Change passwords - Update DB_PASSWORD and MYSQL_PASSWORD
  2. Use HTTPS - Add reverse proxy (nginx/Traefik)
  3. Disable debug - Set APP_DEBUG=false
  4. Configure backups - Backup db-data and storage volumes
  5. Update regularly - Pull latest images periodically

  Docker Hub

  Pre-built image: https://hub.docker.com/r/iamnothardcoded/tastyigniter

  Contributing

  Contributions welcome! Please open an issue or PR.

  Resources

  - https://docs.tastyigniter.com/
  - https://github.com/tastyigniter/TastyIgniter
  - https://hub.docker.com/r/iamnothardcoded/tastyigniter

  License

  This Docker configuration is released under the MIT License.

  TastyIgniter is licensed under the https://github.com/tastyigniter/TastyIgniter/blob/master/LICENSE.

  Support

  - TastyIgniter Community: https://forum.tastyigniter.com/
  - TastyIgniter Issues: https://github.com/tastyigniter/TastyIgniter/issues
  - Docker Setup Issues: https://github.com/iamnothardcoded/tastyigniter-docker/issues