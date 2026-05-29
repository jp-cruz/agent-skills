# Stage 1: Builder - compile dependencies
FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/siddsachar/Thoth.git . && \
    git checkout v3.23.1

RUN pip install --no-cache-dir --user -r requirements.txt && \
    pip install --no-cache-dir --user --upgrade keyring keyrings.alt

# Stage 2: Runtime - minimal image with only runtime dependencies
FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0

RUN useradd -m -u 1000 thoth && \
    mkdir -p /app /home/thoth/.thoth && \
    chown thoth:thoth /home/thoth/.thoth

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ffmpeg git \
    nano vim-tiny \
    less file tree \
    jq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder --chown=thoth:thoth /app /app
COPY --from=builder --chown=thoth:thoth /root/.local /home/thoth/.local

USER thoth

EXPOSE 8080

ENV OLLAMA_BASE_URL=http://host.docker.internal:11434 \
    THOTH_PORT=8080 \
    HOME=/home/thoth \
    PATH=/home/thoth/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PYTHONPATH=/home/thoth/.local/lib/python3.11/site-packages

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

CMD ["python", "launcher.py", "--server", "--no-open", "--port", "8080"]
