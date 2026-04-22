FROM python:3.11-slim

WORKDIR /app

# Instala dependencias del sistema (incluye gcc/g++ para compilar psycopg2)
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    dnsutils \
    libpq-dev \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Actualiza pip a la última versión estable
RUN python -m pip install --upgrade pip

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/

EXPOSE 8000

RUN python3 /app/manage.py migrate
WORKDIR /app
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers","6", "pygoat.wsgi"]
