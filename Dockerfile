FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    buildah \
    ca-certificates \
    curl \
    git \
    jq \
    netavark \
    rsync \
    wget \
    zip \
    && rm -rf /var/lib/apt/lists/*

ENV AQUA_ROOT_DIR="/usr/local/share/aquaproj-aqua"
ENV PATH="${AQUA_ROOT_DIR}/bin:${PATH}"
RUN curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v4.0.2/aqua-installer -o /tmp/aqua-installer && \
    bash /tmp/aqua-installer -i "${AQUA_ROOT_DIR}/bin/aqua" && \
    rm /tmp/aqua-installer
COPY aqua.yaml /tmp/aqua.yaml
RUN cd /tmp && aqua install && rm aqua.yaml

RUN mkdir -p /etc/containers
RUN echo '[storage]\n\
driver = "vfs"\n\
runroot = "/var/lib/containers/runroot"\n\
graphroot = "/var/lib/containers/storage"' > /etc/containers/storage.conf
RUN echo 'unqualified-search-registries = ["docker.io"]' > /etc/containers/registries.conf

RUN echo '#!/bin/bash\n\
shopt -s expand_aliases\n\
case "$1" in\n\
  build) shift; exec buildah bud "$@" ;;\n\
  login) shift; exec buildah login "$@" ;;\n\
  push)  shift; exec buildah push "$@" ;;\n\
  *)     exec buildah "$@" ;;\n\
esac' > /usr/local/bin/docker && chmod +x /usr/local/bin/docker

ENV BUILDAH_ISOLATION=chroot
