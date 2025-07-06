#!/bin/bash
if [ -z "$LOCAL_AI_PASS" ]; then
  echo "Error: LOCAL_AI_PASS environment variable is not set."
  exit 1
fi

HASHED_PASSWORD=$(caddy hash-password --plaintext "$LOCAL_AI_PASS") caddy run --config /Caddyfile &

exec entrypoint.sh "$@"