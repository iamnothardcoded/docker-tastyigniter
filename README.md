# TastyIgniter Docker

Docker setup for [TastyIgniter](https://tastyigniter.com/) - a restaurant online ordering and management system.

## Quick Start

```bash
git clone https://github.com/YOUR-USERNAME/tastyigniter-docker.git
cd tastyigniter-docker
docker-compose -f docker-compose.dev.yml up -d
```

Visit http://localhost:8080 and follow the setup wizard.

## What's Included

- **TastyIgniter v4.0.4** - Latest stable release
- **PHP 8.3** with Apache
- **MariaDB 10.7** - Database server
- **Redis 6** - Caching layer
- **Auto-setup** - Runs install on first launch

## Requirements

- Docker 20.10+
- Docker Compose 1.29+
- 2GB free RAM
- 5GB free disk space

## Features

- Zero-configuration setup
- Persistent database and storage
- Live code editing with volume mounts
- Production-ready foundation
- Automated TastyIgniter installation

## Services

| Service | Port | Description |
|---------|------|-------------|
| app     | 8080 | TastyIgniter web interface |
| db      | 3306 | MariaDB database |
| redis   | -    | Cache backend (internal) |

## Project Structure

```
.
├── Dockerfile.dev           # PHP 8.3 + Apache image
├── docker-compose.dev.yml   # Development stack
├── docker-entrypoint.sh     # Auto-setup script
├── .htaccess                # Apache rewrite rules
└── data/                    # Persistent data
    ├── db/                  # Database files
    └── redis/               # Cache files
```

## Configuration

### Environment Variables

Edit `docker-compose.dev.yml` to customize:

```yaml
environment:
  - APP_URL=http://localhost:8080
  - DB_DATABASE=tastyigniter
  - DB_USERNAME=tastyigniter
  - DB_PASSWORD=somepassword  # Change this!
  - CACHE_DRIVER=redis
```

### Ports

Change exposed ports if needed:

```yaml
ports:
  - "8080:80"  # Change 8080 to your preferred port
```

## Usage

### Start Services

```bash
docker-compose -f docker-compose.dev.yml up -d
```

### View Logs

```bash
docker-compose -f docker-compose.dev.yml logs -f app
```

### Stop Services

```bash
docker-compose -f docker-compose.dev.yml down
```

### Complete Reset

```bash
docker-compose -f docker-compose.dev.yml down -v
rm -rf data/
```

## First Run

1. Start the containers (see above)
2. Wait 30-60 seconds for initialization
3. Visit http://localhost:8080/setup
4. Follow the TastyIgniter setup wizard
5. Use these database credentials:
   - Host: `db`
   - Database: `tastyigniter`
   - Username: `tastyigniter`
   - Password: `somepassword`

## Development

Mount your local TastyIgniter code to develop live:

```yaml
volumes:
  - ./path/to/your/app:/var/www/html
```

Changes to PHP files reflect immediately. For template changes, clear cache:

```bash
docker-compose exec app php artisan cache:clear
```

## Production Use

This is a development setup. For production:

1. Change all passwords
2. Use stronger database credentials
3. Enable HTTPS (add nginx proxy)
4. Set `APP_DEBUG=false`
5. Configure backup strategy
6. Use named volumes instead of bind mounts

## Troubleshooting

### Port already in use

Change port 8080 to another in `docker-compose.dev.yml`

### Permission errors

```bash
docker-compose exec app chown -R www-data:www-data /var/www/html
```

### Database connection failed

Check database is running:
```bash
docker-compose ps
docker-compose logs db
```

### Clear everything and start over

```bash
docker-compose down -v
rm -rf data/
docker-compose up -d
```

## Contributing

Contributions welcome! Please open an issue or PR.

## Resources

- [TastyIgniter Documentation](https://docs.tastyigniter.com/)
- [TastyIgniter GitHub](https://github.com/tastyigniter/TastyIgniter)
- [Docker Documentation](https://docs.docker.com/)

## License

This Docker configuration is released under the MIT License.

TastyIgniter is licensed under the [MIT License](https://github.com/tastyigniter/TastyIgniter/blob/master/LICENSE).

## Support

- TastyIgniter Community: https://forum.tastyigniter.com/
- TastyIgniter Issues: https://github.com/tastyigniter/TastyIgniter/issues
- Docker Setup Issues: [GitHub Issues](https://github.com/YOUR-USERNAME/tastyigniter-docker/issues)
