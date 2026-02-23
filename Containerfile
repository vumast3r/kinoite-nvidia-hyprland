# Containerfile
ARG BASE_IMAGE_NAME=bazzite-nvidia
ARG FEDORA_VERSION=stable

FROM ghcr.io/ublue-os/${BASE_IMAGE_NAME}:${FEDORA_VERSION}

# Copy your custom build script into the container environment
COPY build.sh build_files/build.sh

# Execute the build script to layer your packages
RUN build_files/build.sh
