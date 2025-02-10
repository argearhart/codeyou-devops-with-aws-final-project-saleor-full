#!/bin/bash
set -e

# Wait for database to be ready
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "db" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"

# Run migrations
python3 manage.py migrate --settings=saleor.settings

# Collect static files
python3 manage.py collectstatic --no-input --settings=saleor.settings

# Execute the main container command
exec "$@"