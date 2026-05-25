FROM python:3.11-slim@sha256:a3ab0b966bc4e91546a033e22093cb840908979487a9fc0e6e38295747e49ac0

RUN useradd -m -u 1000 thoth && \
    mkdir -p /app /home/thoth/.thoth && \
    chown thoth:thoth /home/thoth/.thoth

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git curl ffmpeg gcc \
    nano vim-tiny \
    less file tree \
    jq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/siddsachar/Thoth.git . && \
    git checkout deb5d11 && \
    chown -R thoth:thoth /app

USER thoth

RUN pip install --no-cache-dir --user -r requirements.txt && \
    pip install --no-cache-dir --user --upgrade keyring keyrings.alt

EXPOSE 8080

ENV OLLAMA_BASE_URL=http://host.docker.internal:11434 \
    THOTH_PORT=8080 \
    HOME=/home/thoth \
    PATH=/home/thoth/.local/bin:$PATH \
    PYTHONPATH=/home/thoth/.local/lib/python3.11/site-packages:$PYTHONPATH

CMD ["python", "launcher.py", "--server", "--no-open", "--port", "8080"]
