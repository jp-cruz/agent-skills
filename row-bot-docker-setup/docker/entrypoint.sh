#!/bin/bash
# Entrypoint script for Row-Bot container
# Ensures symlink and directory structure are in place on startup

set -e

# Create directory structure for Developer Studio path access
mkdir -p /home/rowbot/Documents/Row-Bot

# Recreate symlink if it doesn't exist
# (lost after container rebuild, but needs to persist for Developer Studio access)
if [ ! -L /home/rowbot/Documents/Row-Bot/projects ]; then
    ln -s /home/rowbot/.row-bot/Documents/Row-Bot/projects /home/rowbot/Documents/Row-Bot/projects 2>/dev/null || true
fi

# Execute the main Row-Bot launcher
exec "$@"
