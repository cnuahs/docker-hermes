#!/bin/bash
# run.sh — convenience wrapper for `docker compose run`
#
# Usage:
#   ./run.sh                        # start interactive TUI
#   ./run.sh --continue             # continue last session
#   ./run.sh --resume <session>     # resume specific session
#
# Prerequisites:
#   - Docker Desktop running
#   - .env.bws with BWS_ACCESS_TOKEN (gitignored)
#   - .hermes/ directory (auto-created if missing)
#
# Passes any additional arguments through to `hermes`.
# The container is removed on exit (--rm).

# 2026-05-29 - Shaun L. Cloherty <s.cloherty@ieee.org>

set -euo pipefail

if [ ! -f ".env.bws" ]; then
    echo "Error: .env.bws file not found."
    echo "Create one with: echo 'BWS_ACCESS_TOKEN=*** > .env.bws"
    echo ".env.bws is gitignored — it will not be committed."
    exit 1
fi

if [ ! -d ".hermes" ]; then
    echo "Creating .hermes directory for persistent state (gitignored)..."
    mkdir -p .hermes
fi

docker compose run --rm hermes "$@"
