# From https://github.com/go-skynet/LocalAI/blob/master/Dockerfile
FROM quay.io/go-skynet/local-ai:v3.1.1-vulkan

RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null &&  \
    apt-get update && \
    apt-get install -y caddy && \
    rm -rf /var/lib/apt/lists/*

COPY Caddyfile /Caddyfile
COPY entrypoint_security.sh /entrypoint_security.sh

ENTRYPOINT ["/entrypoint_security.sh"]

# Needed for Nextcloud AIO so that image cleanup can work.
# Unfortunately, this needs to be set in the Dockerfile in order to work.
LABEL org.label-schema.vendor="Nextcloud"