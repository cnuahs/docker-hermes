#!/bin/bash

# convenience wrapper for loading BWS_ACCESS_TOKEN from .env.bws and
# running the specified service via docker compose

# 2026-05-25 - Shaun L. Cloherty <s.cloherty@ieee.org>

set -euo pipefail

# check for target service name
if [ $# -eq 0 ]; then
    echo "Error: Please specify a service name as the first argument."
    echo "Usage: $0 <service-name> [args...]"
    exit 1
fi

# extract the first argument as the target service name
SERVICE="$1"
shift

# load BWS_ACCESS_TOKEN from .env.bws if present
if [ -f ".env.bws" ]; then
    BWS_ACCESS_TOKEN="$(grep '^BWS_ACCESS_TOKEN=' .env.bws | head -1 | cut -d= -f2-)"
    if [ -n "$BWS_ACCESS_TOKEN" ]; then
        export BWS_ACCESS_TOKEN
        echo "BWS_ACCESS_TOKEN loaded from .env.bws."
    fi
fi

case "$SERVICE" in
    "hermes" | "tui")
        docker compose run --rm hermes bws run -- hermes "$@"
        ;;
    "gateway")
        docker compose up -d gateway "$@"
        ;;
    *)
        echo "Error: Unknown service '$SERVICE'."
        echo "Valid services are: hermes|tui, gateway"
        exit 1
        ;;
esac
