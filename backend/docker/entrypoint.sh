#!/bin/sh

# Set appropriate settings based on DJANGO_DEBUG
if [ "$DJANGO_DEBUG" = "True" ]; then
    export DJANGO_SETTINGS_MODULE=config.settings.development
else
    export DJANGO_SETTINGS_MODULE=config.settings.production
fi

# Wait for DB
echo "Waiting for PostgreSQL..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 0.1
done
echo "PostgreSQL started"

# Migrations
# python manage.py migrate --noinput

# Collect static files
# python manage.py collectstatic --noinput

exec "$@"
