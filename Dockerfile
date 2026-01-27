# From https://github.com/go-skynet/LocalAI/blob/master/Dockerfile
FROM quay.io/go-skynet/local-ai:master-gpu-vulkan

# Needed for Nextcloud AIO so that image cleanup can work.
# Unfortunately, this needs to be set in the Dockerfile in order to work.
LABEL org.label-schema.vendor="Nextcloud"