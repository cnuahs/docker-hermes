# 2026-05-24 - Shaun L. Cloherty <s.cloherty@ieee.org>

FROM nousresearch/hermes-agent:main

# Copy bws binary from official Bitwarden Secrets Manager image
COPY --from=ghcr.io/bitwarden/bws /bin/bws /usr/local/bin/bws
