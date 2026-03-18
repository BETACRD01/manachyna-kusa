#!/bin/bash
# run_prod.sh - Local execution using Gunicorn

# Activate venv
source venv/bin/activate

# Gunicorn configuration
# In local dev, we can use runserver or gunicorn. 
# The master_launcher uses this script.
echo "Starting Gunicorn on 127.0.0.1:8000..."
exec gunicorn config.wsgi:application \
    --name manachyna_backend \
    --bind 127.0.0.1:8000 \
    --workers 3 \
    --log-level=info \
    --reload
