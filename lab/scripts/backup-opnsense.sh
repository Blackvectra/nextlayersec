#!/usr/bin/env bash
set -euo pipefail
# Exports OPNsense config to configurations/firewall/ with timestamp.
OUT_DIR="configurations/firewall"
mkdir -p "$OUT_DIR"
TS="$(date +%Y%m%d-%H%M%S)"
# Replace with your API creds & URL (read-only key recommended)
OPNSENSE_URL="${OPNSENSE_URL:?set OPNSENSE_URL}"
OPNSENSE_KEY="${OPNSENSE_KEY:?set OPNSENSE_KEY}"
OPNSENSE_SECRET="${OPNSENSE_SECRET:?set OPNSENSE_SECRET}"

curl -sS -u "${OPNSENSE_KEY}:${OPNSENSE_SECRET}" \
  "${OPNSENSE_URL%/}/api/core/backup/download" \
  -o "${OUT_DIR}/opnsense-config-${TS}.xml"

echo "Saved ${OUT_DIR}/opnsense-config-${TS}.xml"
