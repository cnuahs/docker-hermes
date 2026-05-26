# docker-hermes

![Docker Image CI](https://github.com/cnuahs/docker-hermes/actions/workflows/build-docker.yml/badge.svg)
![ghcr.io](https://img.shields.io/badge/ghcr.io-enabled-brightgreen)

This repository builds and publishes a custom Docker image for [Hermes](https://github.com/NousResearch/hermes-agent) -- _"the agent that grows with you"_.

## Base image

`nousresearch/hermes-agent:main` — tracks the latest build on the `main` branch.

## GHCR image

`ghcr.io/cnuahs/hermes-agent:latest`

## What's included

- Everything from `nousresearch/hermes-agent:main`
- `bws` (Bitwarden Secrets Manager CLI)

## Secrets management

Secrets (API keys, tokens) are stored in [Bitwarden Secrets Manager](https://bitwarden.com/products/secrets-manager/)
and injected at container startup via `bws run`. No secrets are written to disk — not in
`.env`, not in the container filesystem.

## Usage

Set the machine access token in your shell environment:

```bash
export BWS_ACCESS_TOKEN=<token>
```

Then start hermes or the gateway:

```bash
docker compose run --rm hermes                        # interactive chat
docker compose run --rm hermes hermes --continue      # continue last session
docker compose run --rm hermes hermes --resume <s>    # resume session <s>
docker compose up -d gateway                          # start gateway daemon
```

A convenience wrapper, `bin/run.sh`, is provided to perform these
steps, loading the token from `.env.bws` automatically:

```bash
./bin/run.sh hermes          # interactive chat
./bin/run.sh gateway         # start gateway daemon
```

To use the wrapper, the `.env.bws` file in the working directory should provide
the machine access token, e.g.,

```
BWS_ACCESS_TOKEN=<your-machine-access-token>
```

`.env.bws` is gitignored. Never commit it.

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
