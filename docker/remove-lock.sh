#!/bin/sh
# Remove stale s6-log lock files from previous runs
rm -f /opt/data/logs/gateways/*/lock 2>/dev/null || true
