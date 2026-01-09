# From https://github.com/go-skynet/LocalAI/blob/master/Dockerfile
FROM quay.io/go-skynet/local-ai:master-gpu-vulkan

RUN apt-get update && \
    apt-get install -y caddy && \
    rm -rf /var/lib/apt/lists/*

COPY Caddyfile /Caddyfile
COPY --chmod=755 entrypoint_security.sh /entrypoint_security.sh

ENTRYPOINT ["/entrypoint_security.sh"]

# Needed for Nextcloud AIO so that image cleanup can work.
# Unfortunately, this needs to be set in the Dockerfile in order to work.
LABEL org.label-schema.vendor="Nextcloud"