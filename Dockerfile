# 2026-05-20 - Shaun L. Cloherty <s.cloherty@ieee.org>

FROM nousresearch/hermes-agent:main

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gh && \
    apt-get clean -y && rm -rf /var/lib/apt/lists/*

