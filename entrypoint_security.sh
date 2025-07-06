#!/bin/bash

if [ -z "$LOCAL_AI_PASS" ]; then
  echo "Error: LOCAL_AI_PASS environment variable is not set. Caddy will not start."
else
  HASHED_PASSWORD=$(caddy hash-password --plaintext "$LOCAL_AI_PASS")
  export HASHED_PASSWORD
  caddy run --config /Caddyfile &
fi

bash /entrypoint.sh "$@"