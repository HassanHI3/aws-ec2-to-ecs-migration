# Stage 1: install dependencies
FROM python:3.12-slim AS builder
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

# Stage 2: run the app
FROM python:3.12-slim
WORKDIR /app

# wget is needed for the healthcheck (slim image doesn't include it)
RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local
COPY . .

RUN useradd appuser
USER appuser

EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]