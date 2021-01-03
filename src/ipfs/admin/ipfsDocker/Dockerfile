FROM ipfs/go-ipfs:latest
LABEL maintainer="Steven Allen <steven@stebalien.com>"

# Install deps
RUN apt-get update && apt-get install -y \
  libssl-dev \
  ca-certificates \
  fuse
