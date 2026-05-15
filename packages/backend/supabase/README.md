# Supabase Local Development

This directory contains configuration for running Supabase locally in development and CI environments.

## Files

- `config.toml` - Supabase CLI configuration (minimal services enabled for testing)
- `migrations/` - Database migrations (copied from `prisma/migrations/`)

## Usage

### Local Development

```bash
# Start local Supabase stack
supabase start

# Stop local stack
supabase stop
```

### CI Environment

The GitHub Actions workflow automatically:
1. Installs Supabase CLI
2. Runs `supabase init` and `supabase start`
3. Applies migrations
4. Runs tests
5. Cleans up with `supabase stop`

## Database Connection

When Supabase is running locally:
- Host: `127.0.0.1`
- Port: `54322`
- Database: `postgres`
- User: `postgres`
- Password: `postgres`
- Connection string: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
