FROM ubuntu:26.04

RUN apt-get update && apt-get install -y \
    buildah \
    fuse-overlayfs \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/containers
RUN echo '[storage]\n\
driver = "vfs"\n\
[storage.options]\n\
mount_program = "/usr/bin/fuse-overlayfs"' > /etc/containers/storage.conf

RUN echo '#!/bin/bash\n\
shopt -s expand_aliases\n\
case "$1" in\n\
  build) shift; exec buildah bud "$@" ;;\n\
  login) shift; exec buildah login "$@" ;;\n\
  push)  shift; exec buildah push "$@" ;;\n\
  *)     exec buildah "$@" ;;\n\
esac' > /usr/local/bin/docker && chmod +x /usr/local/bin/docker

ENV BUILDAH_ISOLATION=chroot
