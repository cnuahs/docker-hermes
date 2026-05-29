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
docker compose run --rm hermes                        # start session
docker compose run --rm hermes hermes --continue      # continue last session
docker compose run --rm hermes hermes --resume <s>    # resume session <s>
docker compose up -d gateway                          # start gateway daemon
```

A convenience wrapper, `run.sh`, is provided to perform these
steps, loading the token from `.env.bws` automatically:

```bash
./run.sh hermes          # start interactive chat
./run.sh gateway         # start gateway daemon
```

To use the wrapper, the `.env.bws` file in the working directory should provide
the machine access token, e.g.,

```
BWS_ACCESS_TOKEN=<your-machine-access-token>
```

`.env.bws` is gitignored. Never commit it.

## Updating the image

The image is built and published to GHCR by Github Actions. The workflow
runs automatically when the Dockerfile or workflow file changes on `main`,
or can be triggered manually via the Actions tab (`workflow_dispatch`).

### Manual rebuild (no code changes needed)

To pick up the latest base image without triggering the Github workflow:

1. Build and test locally:

   ```bash
   docker build --pull -t ghcr.io/cnuahs/hermes-agent:test .
   docker compose run --rm hermes
   ```

   `--pull` ensures the latest `nousresearch/hermes-agent:main` base image
   is used.

2. If the test succeeds, trigger the Github workflow:

   - Go to **Actions > Build and push Hermes Agent Docker image > Run workflow**
   - Or via CLI: `gh workflow run build-docker.yml`
   - Or via REST API:

     ```bash
     curl -X POST \
       -H "Authorization: token $GITHUB_TOKEN" \
       -H "Accept: application/vnd.github+json" \
       https://api.github.com/repos/<owner>/docker-hermes/actions/workflows/build-docker.yml/dispatches \
       -d '{"ref":"main"}'
     ```

   The workflow builds a multi-arch image, generates an SBOM and attestation,
   and pushes to GHCR.

3. Pull the updated image:

   ```bash
   docker compose pull gateway
   docker compose up -d gateway
   ```

### Image changes

For actual Dockerfile changes, commit and push to `main`:

```bash
git add Dockerfile
git commit
git push origin main
```

The workflow builds and pushes to GHCR automatically. Then pull and restart as
in 3. above.

## Checking the base image SHA

Each workflow build records the exact base image digest as a label:

```bash
docker inspect ghcr.io/cnuahs/hermes-agent:latest \
  --format='{{index .Config.Labels "org.opencontainers.image.base.digest"}}'
```

This returns the SHA256 digest of the base image used (e.g., `sha256:abc123...`). If you need to pin to a specific base, use this SHA in the Dockerfile:

```dockerfile
FROM nousresearch/hermes-agent@sha256:abc123...
```

## Adding tools

Edit the `Dockerfile`, add your `apt-get install` lines, test locally then commit and push to `main`. The workflow rebuilds and pushes automatically.
