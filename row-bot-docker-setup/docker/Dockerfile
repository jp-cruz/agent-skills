# ============================================================================
# ROW-BOT VERSION PIN — READ BEFORE UPGRADING
#
# This Docker setup is built and tested against Row-Bot v4.0.1
# (released 2026-06-06: https://github.com/siddsachar/row-bot/releases).
# Later Row-Bot versions may change launcher flags, env vars, or data
# layout — this skill has NOT been validated against anything newer.
#
# To upgrade: change ROW_BOT_VERSION below to a newer release tag, then
# rebuild with `docker-compose build --no-cache` and re-test.
# ============================================================================
ARG ROW_BOT_VERSION=v4.0.1

# Stage 1: Builder - compile dependencies
FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0 AS builder
ARG ROW_BOT_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    git gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Pinned to a release tag (not `main`) so every user builds the exact same
# Row-Bot version regardless of when they build or what Docker has cached.
RUN git clone --branch "${ROW_BOT_VERSION}" --depth 1 \
    https://github.com/siddsachar/row-bot.git .

RUN pip install --no-cache-dir --user -r requirements.txt && \
    pip install --no-cache-dir --user --upgrade keyring keyrings.alt

# Stage 2: Runtime - minimal image with only runtime dependencies
FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0
ARG ROW_BOT_VERSION

LABEL org.opencontainers.image.title="Row-Bot (Docker)" \
      org.opencontainers.image.description="Containerized Row-Bot. Built for Row-Bot ${ROW_BOT_VERSION}; not validated against later versions." \
      org.opencontainers.image.version="${ROW_BOT_VERSION}" \
      org.opencontainers.image.source="https://github.com/siddsachar/row-bot" \
      ai.row-bot.docker-skill.built-for="${ROW_BOT_VERSION}"

# Pre-create both volume mountpoints with rowbot ownership so the named
# volumes initialize writable by the app (Docker creates missing
# mountpoints as root otherwise).
RUN useradd -m -u 1000 rowbot && \
    mkdir -p /app /home/rowbot/.row-bot /home/rowbot/Documents/Row-Bot && \
    chown -R rowbot:rowbot /home/rowbot/.row-bot /home/rowbot/Documents

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
COPY --chown=rowbot:rowbot entrypoint.sh /home/rowbot/entrypoint.sh
RUN chmod +x /home/rowbot/entrypoint.sh

USER rowbot

EXPOSE 8080

ENV OLLAMA_BASE_URL=http://host.docker.internal:11434 \
    ROW_BOT_PORT=8080 \
    HOME=/home/rowbot \
    PATH=/home/rowbot/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PYTHONPATH=/home/rowbot/.local/lib/python3.11/site-packages

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

ENTRYPOINT ["/home/rowbot/entrypoint.sh"]
CMD ["python", "launcher.py", "--server", "--no-open", "--port", "8080"]
