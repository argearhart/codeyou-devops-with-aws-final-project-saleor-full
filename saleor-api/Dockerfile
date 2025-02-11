FROM python:3.12-slim AS base
ARG SECRET_KEY
ARG STATIC_URL

ENV SECRET_KEY=${SECRET_KEY} \
    STATIC_URL=${STATIC_URL} \
    POETRY_VERSION=1.8.4 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH="/app" 

WORKDIR /app

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    python3-dev\
    libffi-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    git \
    gettext \
    libffi8 \
    libgdk-pixbuf2.0-0 \
    liblcms2-2 \
    libopenjp2-7 \
    libssl3 \
    libtiff6 \
    libwebp7 \
    shared-mime-info \
    mime-support \
    libpq5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN pip install --no-cache-dir --upgrade pip

# Install Poetry
RUN pip install --no-cache-dir poetry==1.8.4

RUN poetry config virtualenvs.create false

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Install dependencies
RUN poetry install --no-root --no-cache --no-interaction
RUN poetry run pip install "pywatchman<2.0.0"


# Create a non-root user
RUN addgroup --system saleor && adduser --system --ingroup saleor saleor
RUN chown -R saleor:saleor /app
USER saleor

WORKDIR /app 

COPY . /app

RUN dos2unix /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh



# Expose API port
EXPOSE 8000


ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "--bind", ":8000", "--workers", "4", "--worker-class", "saleor.asgi.gunicorn_worker.UvicornWorker", "saleor.asgi:application"]