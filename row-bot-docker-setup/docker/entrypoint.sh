#!/bin/bash
# Entrypoint script for Row-Bot container
# Ensures symlink and directory structure are in place on startup

set -e

# Workspace (~/Documents/Row-Bot) is a mounted volume; ensure the projects
# symlink target exists inside the data volume so the link is never dangling
mkdir -p /home/rowbot/.row-bot/Documents/Row-Bot/projects

# Recreate symlink if it doesn't exist
# (keeps projects in the data volume for continuity with existing
# deployments and bare-metal migrations; Developer Studio reads this path)
if [ ! -e /home/rowbot/Documents/Row-Bot/projects ]; then
    ln -s /home/rowbot/.row-bot/Documents/Row-Bot/projects /home/rowbot/Documents/Row-Bot/projects 2>/dev/null || true
fi

# Execute the main Row-Bot launcher
exec "$@"
