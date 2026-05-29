# docker-hermes — per-project setup

This template sets up Hermes Agent with Bitwarden Secrets Manager for a single project/repo. Each project gets its own `.hermes/` directory for persistent state (sessions, logs, skills).

## What's included

- `docker-compose.yml` -- TUI session
- `docker-compose.gateway.yml` -- Gateway service
- `run.sh` -- Convenience wrapper for TUI
- `.env.bws` -- Machine access token (gitignored)
- `.gitignore` -- Excludes `.hermes/` and `.env.bws`

## Prerequisites

- Docker Desktop running
- Bitwarden Secrets Manager machine account access token

## Setup

1. Copy these files into your project repo root.

2. In `docker-compose.yml` and `docker-compose.gateway.yml`, replace `PROJECT_NAME` with your project name:

   ```bash
   sed -i 's/PROJECT_NAME/my-project/g' docker-compose.yml docker-compose.gateway.yml
   ```

3. Create `.env.bws` with your machine access token:

   ```
   BWS_ACCESS_TOKEN=your-token-here
   ```

4. Create the `.hermes/` directory:

   ```bash
   mkdir -p .hermes
   ```

5. Ensure `.hermes/` and `.env.bws` are in your `.gitignore`:

   ```
   .hermes/
   .env.bws
   ```

## Usage

### Interactive TUI

```bash
./run.sh
```

With options:

```bash
./run.sh --continue          # continue last session
./run.sh --resume <session>  # resume specific session
```

Or directly via compose:

```bash
docker compose run --rm hermes --continue
```

### Gateway

```bash
docker compose -f docker-compose.gateway.yml up -d gateway
docker compose -f docker-compose.gateway.yml logs -f gateway
```

## How it works

- The project repo is mounted at `/opt/data/workspace/` inside the container
- Persistent state (sessions, logs, skills) lives in `.hermes/` mounted at `/opt/data/`
- API keys and tokens are fetched from Bitwarden Secrets Manager at startup via `bws run`
- The `BWS_ACCESS_TOKEN` env var provides the machine account token for authentication
- No secrets are written to disk — they exist only in the container's process environment

## Project structure

```
my-project/
  .hermes/              -- persistent state (sessions, logs, skills, memories)
    sessions/
    logs/
    memories/
    skills/
    ...
  .env.bws              -- machine access token (gitignored)
  .gitignore            -- excludes .hermes/ and .env.bws
  docker-compose.yml    -- TUI session
  run.sh                -- convenience wrapper
  AGENTS.md             -- project-specific agent context
  ...                   -- your project files
```

## Notes

- Each project gets its own isolated `.hermes/` directory
- Sessions and state are persisted across container restarts
- The gateway (if used) maintains a single long-lived process (use `restart: unless-stopped`)
- The TUI creates a fresh container each time (removed on exit with `--rm`)
