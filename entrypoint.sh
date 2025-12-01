#!/bin/bash
# Entrypoint to ensure DISPLAY is set correctly

# If DISPLAY not set, try to detect from X11 socket
if [ -z "$DISPLAY" ]; then
    if [ -d /tmp/.X11-unix ]; then
        # Find first available display socket
        for socket in /tmp/.X11-unix/X[0-9]*; do
            if [ -S "$socket" ] 2>/dev/null; then
                display_num=$(basename "$socket" | sed 's/X//')
                export DISPLAY=:${display_num}
                break
            fi
        done
    fi
fi

# Verify DISPLAY is set
if [ -z "$DISPLAY" ]; then
    echo "Error: DISPLAY environment variable not set" >&2
    echo "Swarm requires X11 display. Set DISPLAY before running:" >&2
    echo "  export DISPLAY=:0" >&2
    echo "  docker run -e DISPLAY=\$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ..." >&2
    exit 1
fi

# Run Swarm with provided arguments
exec "$@"
