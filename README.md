# docker-hermes

![Docker Image CI](https://github.com/cnuahs/docker-hermes/actions/workflows/build-docker.yml/badge.svg)
![GitHub release](https://img.shields.io/github/v/tag/cnuahs/docker-hermes)
![ghcr.io](https://img.shields.io/badge/ghcr.io-enabled-brightgreen)

This repository builds and publishes a custom Docker image for [Hermes](https://github.com/NousResearch/hermes-agent) -- _"the agent that grows with you"_.

## Base image

`nousresearch/hermes-agent:main` — tracks the latest build on the `main` branch.

## GHCR image

`ghcr.io/cnuahs/hermes-agent:latest`

## What's included

- Everything from `nousresearch/hermes-agent:main`
- `gh` (GitHub CLI) 

## Usage

1. Clone this repo alongside your existing Hermes setup.

2. To launch the gateway:

   ```bash
   docker compose up -d gateway
   ```

3. To launch the interractive TUI:

   ```bash
   docker compose up
   ```

   or, to pass command line argument to the agent process,

   ```bash
   docker compse run --rm hermes hermes [args]
   ```

   For example,

   ```bash
   docker compose run --rm hermes hermes --continue  # continue the last session
   ```
   ```bash
   docker compose run --rm hermes hermes --resume <session>  # resume session <session>
   ```

## Updating the image

1. Clone this repo.
2. Edit Dockerfile.
3. Commit and push to `main`.

When pushed to `main`, GitHub Actions builds the image and pushes to GHCR automatically.

Then,

```bash
docker compose pull gateway
docker compose up -d gateway
```

## Checking the base image SHA

Each build records the exact base image digest as a label:

```bash
docker inspect ghcr.io/cnuahs/hermes-agent:latest \
  --format='{{index .Config.Labels "org.opencontainers.image.base.digest"}}'
```

This returns the SHA256 digest of the base image used (e.g., `sha256:abc123...`). If you need to pin to a specific base, use this SHA in the Dockerfile:

```dockerfile
FROM nousresearch/hermes-agent@sha256:abc123...
```

## Adding more tools

Edit the `Dockerfile`, add your `apt-get install` lines, commit and push to `main`. The workflow rebuilds and pushes automatically.
