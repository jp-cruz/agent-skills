# Stage 1: Builder - compile dependencies
FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/siddsachar/row-bot.git . && \
    git checkout latest

RUN pip install --no-cache-dir --user -r requirements.txt && \
    pip install --no-cache-dir --user --upgrade keyring keyrings.alt

# Stage 2: Runtime - minimal image with only runtime dependencies
FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0

RUN useradd -m -u 1000 rowbot && \
    mkdir -p /app /home/rowbot/.row-bot && \
    chown rowbot:rowbot /home/rowbot/.row-bot

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ffmpeg git \
    nano vim-tiny \
    less file tree \
    jq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder --chown=rowbot:rowbot /app /app
COPY --from=builder --chown=rowbot:rowbot /root/.local /home/rowbot/.local

# Copy entrypoint script to ensure symlinks persist across container restarts
COPY --chown=rowbot:rowbot docker/entrypoint.sh /home/rowbot/entrypoint.sh
RUN chmod +x /home/rowbot/entrypoint.sh

USER rowbot

EXPOSE 8080

ENV OLLAMA_BASE_URL=http://host.docker.internal:11434 \
    ROWBOT_PORT=8080 \
    HOME=/home/rowbot \
    PATH=/home/rowbot/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PYTHONPATH=/home/rowbot/.local/lib/python3.11/site-packages

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

ENTRYPOINT ["/home/rowbot/entrypoint.sh"]
CMD ["python", "launcher.py", "--server", "--no-open", "--port", "8080"]
