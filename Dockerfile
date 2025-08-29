# Use Python 3.8 because the repo targets Django 2.2.x
FROM python:3.8-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1

WORKDIR /app

# System libs – helpful if Pillow needs them
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt /app/

# Old allauth needs legacy setuptools; then install requirements without build isolation
RUN python -m pip install --upgrade pip && \
    pip install "setuptools==57.5.0" "wheel<0.40" && \
    pip install --no-build-isolation -r requirements.txt

# Copy the rest of the project
COPY . /app

# Adjust if your dev settings module is different
ENV DJANGO_SETTINGS_MODULE=djecommerce.settings.development

EXPOSE 8000

# Migrate then run
CMD ["sh","-c","python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
