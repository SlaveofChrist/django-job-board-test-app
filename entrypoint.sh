#!/bin/sh
set -e

echo "Running migrations..."
python manage.py migrate --noinput

echo "Initializing Azure Storage (Uploading static/media files)..."
python backend/initialize_azure.py

echo "Starting Gunicorn..."
exec gunicorn job_board.wsgi:application --bind 0.0.0.0:8000 --workers 2
