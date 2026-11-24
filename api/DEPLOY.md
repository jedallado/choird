# Deploying the Choird API to Railway

This repo is a monorepo. The Laravel API lives in `api/`. Railway is configured via `api/railway.toml`.

## 1. Push to GitHub

Ensure this repository is pushed to GitHub (Railway deploys from your connected repo).

## 2. Create a Railway project

1. Go to [railway.com](https://railway.com) and create a **New Project**.
2. Choose **Deploy from GitHub repo** and select this repository.

## 3. Add a database

1. On the project canvas, click **+ New** → **Database** → **MySQL** or **PostgreSQL**.
2. Wait for the database service to finish provisioning.

## 4. Configure the API service

Open the API service **Settings**:

| Setting | Value |
|--------|--------|
| **Root Directory** | `api` |
| **Config File** | `/api/railway.toml` |

The app is built from `api/Dockerfile`, which installs required PHP extensions (`intl`, `zip`, `pdo_pgsql`, etc.), runs Composer and npm builds, and starts Laravel via `php artisan serve`.

### Generate a public URL

In **Settings → Networking**, click **Generate Domain**. Copy the URL for `APP_URL`.

## 5. Set environment variables

In the API service **Variables** tab, add:

| Variable | Value |
|----------|--------|
| `APP_ENV` | `production` |
| `APP_DEBUG` | `false` |
| `APP_KEY` | Output of `php artisan key:generate --show` (run locally in `api/`) |
| `APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` |
| `LOG_CHANNEL` | `stderr` |
| `LOG_STDERR_FORMATTER` | `\Monolog\Formatter\JsonFormatter` |
| `DB_CONNECTION` | `mysql` or `pgsql` (match your database service) |
| `DB_URL` | `${{MySQL.DATABASE_URL}}` or `${{Postgres.DATABASE_URL}}` |
| `SESSION_DRIVER` | `database` |
| `CACHE_STORE` | `database` |
| `QUEUE_CONNECTION` | `database` |
| `MAIL_MAILER` | `smtp` (or another real mailer) |
| `MAIL_HOST` | Your mail host |
| `MAIL_PORT` | `587` |
| `MAIL_USERNAME` | SMTP username |
| `MAIL_PASSWORD` | SMTP password |
| `MAIL_FROM_ADDRESS` | Address new users see the password email from |
| `MAIL_FROM_NAME` | `Choird` |

Replace `MySQL` / `Postgres` in `DB_URL` with your database service name if you renamed it. Creating a user in the admin panel emails them a temporary password, so those mail settings need to be real in production. The default `log` mailer only writes the message to the log.

## 6. Deploy

Click **Deploy**. On each deploy, Railway will:

1. Build the Docker image (`composer install`, `npm run build`)
2. Run migrations and cache config/routes/views (via `railway/init-app.sh`)
3. Start the web server (`railway/start.sh`)

Health checks use Laravel’s `/up` endpoint.

## 7. Create an admin user

Deploying runs migrations. That migration marks every user that already exists as `admin`, so a current Filament account keeps full access.

On a new environment, create an admin after the first successful deploy:

```bash
railway link          # from api/ directory, if using Railway CLI
railway run php artisan choird:make-admin
```

Or use the Railway dashboard **Shell** for the API service and run the same command. This account can sign in to Filament and to `POST /api/login`. `make:filament-user` does not set a role, so a user created that way is a member and cannot open the panel.

## 8. Verify the API

```bash
curl https://YOUR-RAILWAY-DOMAIN.up.railway.app/up
```

`/api/songs` and `/api/sets` require a bearer token from `POST /api/login`. Filament admin panel: `https://YOUR-RAILWAY-DOMAIN.up.railway.app/admin`

## Optional: queue worker service

The app uses database-backed queues. For background jobs, add a second service from the same repo:

| Setting | Value |
|--------|--------|
| **Root Directory** | `api` |
| **Start Command** | `chmod +x ./railway/run-worker.sh && sh ./railway/run-worker.sh` |

Copy the same environment variables from the API service (especially `DB_URL` and `APP_KEY`). Do **not** expose this service publicly.

## Mobile app

Point the Flutter app at your Railway URL:

```bash
flutter run --dart-define=API_BASE_URL=https://YOUR-RAILWAY-DOMAIN.up.railway.app
```

Or set `localApiBaseUrl` in `mobile/lib/config/api_config.local.dart`.
