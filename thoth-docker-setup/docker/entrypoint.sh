#!/bin/bash
# Entrypoint script for Thoth container
# Ensures symlink and directory structure are in place on startup

set -e

# Create directory structure for Developer Studio path access
mkdir -p /home/thoth/Documents/Thoth

# Recreate symlink if it doesn't exist
# (lost after container rebuild, but needs to persist for Developer Studio access)
if [ ! -L /home/thoth/Documents/Thoth/projects ]; then
    ln -s /home/thoth/.thoth/Documents/Thoth/projects /home/thoth/Documents/Thoth/projects 2>/dev/null || true
fi

# Execute the main Thoth launcher
exec "$@"
