FROM python:3.11-slim

# set work directory
WORKDIR /app

# Instalar dependencias del sistema incluyendo gcc y g++ para compilar psycopg2
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    gcc \
    g++ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Actualizar pip a una versión más reciente y estable
RUN python -m pip install --upgrade pip

# Copiar requirements.txt y instalar dependencias de Python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# copy project
COPY . /app/

# expose port
EXPOSE 8000

# migrar base de datos (si es necesario) y ejecutar gunicorn
RUN python3 /app/manage.py migrate
WORKDIR /app
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers","6", "pygoat.wsgi"]
