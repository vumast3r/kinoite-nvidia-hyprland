# Containerfile
ARG BASE_IMAGE_NAME=bazzite-nvidia
ARG FEDORA_VERSION=stable

FROM ghcr.io/ublue-os/${BASE_IMAGE_NAME}:${FEDORA_VERSION}

# Copy your custom build script into the container environment
COPY build.sh /tmp/build.sh

# Execute the build script to layer your packages
RUN /tmp/build.sh
