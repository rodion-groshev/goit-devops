#!/usr/bin/env bash
set -e

python /app/wait_for_db.py
python manage.py migrate --noinput
python manage.py collectstatic --noinput || true
python manage.py runserver 0.0.0.0:8000
