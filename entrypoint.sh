#!/bin/bash
# Entrypoint script to start Xvfb or use host X11 display

# If DISPLAY is not set (no X11 forwarding), use Xvfb
if [ -z "$DISPLAY" ]; then
    # Start Xvfb virtual framebuffer in background
    Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
    XVFB_PID=$!
    sleep 2

    # Verify Xvfb is running
    if ! ps -p $XVFB_PID > /dev/null 2>&1; then
        echo "Error: Failed to start Xvfb" >&2
        exit 1
    fi

    export DISPLAY=:99
fi

# Run Swarm with provided arguments
exec "$@"
