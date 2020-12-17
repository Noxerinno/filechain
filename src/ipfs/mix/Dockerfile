FROM golang:1.14
LABEL maintainers="Frantz Darbon <frantz.darbon@telecomnancy.eu>; Johan Tombre <johan.tombre@telecomnancy.eu>; Frederic Vaz <frederic.vaz@telecomnancy.eu>"

# Install deps
RUN apt-get update && apt-get install -y \
  libssl-dev \
  ca-certificates \
  fuse

ENV GOPATH      /go
ENV SRC_DIR     /go-ipfs
ENV SRC_PATH    $GOPATH/src/github.com/ipfs/ipfs-cluster
ENV GO111MODULE on
ENV GOPROXY     https://proxy.golang.org

# Download packages first so they can be cached.
COPY go.mod go.sum $SRC_DIR/
RUN cd $SRC_DIR \
  && go mod download

COPY . $SRC_DIR

# Preload an in-tree but disabled-by-default plugin by adding it to the IPFS_PLUGINS variable
# e.g. docker build --build-arg IPFS_PLUGINS="foo bar baz"
ARG IPFS_PLUGINS

# Build the thing.
# Also: fix getting HEAD commit hash via git rev-parse.
RUN cd $SRC_DIR \
  && mkdir .git/objects \
  && make build GOTAGS=openssl IPFS_PLUGINS=$IPFS_PLUGINS

# Get su-exec, a very minimal tool for dropping privileges,
# and tini, a very minimal init daemon for containers
ENV SUEXEC_VERSION v0.2
ENV TINI_VERSION v0.18.0
RUN set -x \
  && cd /tmp \
  && git clone https://github.com/ncopa/su-exec.git \
  && cd su-exec \
  && git checkout -q $SUEXEC_VERSION \
  && make \
  && cd /tmp \
  && wget -q -O tini https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini \
  && chmod +x tini


#------------------------------------------------------
# Now comes the actual target image, which aims to be as small as possible.
FROM busybox:1.31.1-glibc
LABEL maintainers="Frantz Darbon <frantz.darbon@telecomnancy.eu>; Johan Tombre <johan.tombre@telecomnancy.eu>; Frederic Vaz <frederic.vaz@telecomnancy.eu>"

#IPFS-Cluster var
ENV IPFS_PATH /data/ipfs
ENV IPFS_CLUSTER_PATH      /data/ipfs-cluster
ENV IPFS_CLUSTER_CONSENSUS crdt

# Swarm TCP; should be exposed to the public
EXPOSE 4001
# Daemon API; must not be exposed publicly but to client services under you control
EXPOSE 5001
# Web Gateway; can be exposed publicly with a proxy, e.g. as https://ipfs.example.org
EXPOSE 8080
# Swarm Websockets; must be exposed publicly when the node is listening using the websocket transport (/ipX/.../tcp/8081/ws).
EXPOSE 8081
#IPFS-Cluster
EXPOSE 9094
EXPOSE 9095
EXPOSE 9096

# Get the ipfs binary, entrypoint script, and TLS CAs from the build container.
COPY --from=0 $SRC_DIR/cmd/ipfs/ipfs /usr/local/bin/ipfs
COPY --from=0 $SRC_DIR/bin/container_daemon /usr/local/bin/start_ipfs
COPY --from=0 /tmp/su-exec/su-exec /sbin/su-exec
COPY --from=0 /tmp/tini /sbin/tini
COPY --from=0 /bin/fusermount /usr/local/bin/fusermount
COPY --from=0 /etc/ssl/certs /etc/ssl/certs
#IPFS-Cluster
COPY --from=builder $GOPATH/bin/ipfs-cluster-service /usr/local/bin/ipfs-cluster-service
COPY --from=builder $GOPATH/bin/ipfs-cluster-ctl /usr/local/bin/ipfs-cluster-ctl
COPY --from=builder $GOPATH/bin/ipfs-cluster-follow /usr/local/bin/ipfs-cluster-follow
COPY --from=builder $SRC_PATH/docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --from=builder /tmp/su-exec/su-exec /sbin/su-exec
COPY --from=builder /tmp/tini /sbin/tini
COPY --from=builder /etc/ssl/certs /etc/ssl/certs


# Add suid bit on fusermount so it will run properly
RUN chmod 4755 /usr/local/bin/fusermount

# Fix permissions on start_ipfs (ignore the build machine's permissions)
RUN chmod 0755 /usr/local/bin/start_ipfs

# This shared lib (part of glibc) doesn't seem to be included with busybox.
COPY --from=0 /lib/*-linux-gnu*/libdl.so.2 /lib/

# Copy over SSL libraries.
COPY --from=0 /usr/lib/*-linux-gnu*/libssl.so* /usr/lib/
COPY --from=0 /usr/lib/*-linux-gnu*/libcrypto.so* /usr/lib/

# Create the fs-repo directory and switch to a non-privileged user.
RUN mkdir -p $IPFS_PATH \
  && adduser -D -h $IPFS_PATH -u 1000 -G users ipfs \
  && chown ipfs:users $IPFS_PATH
#IPFS-Cluster
RUN mkdir -p $IPFS_CLUSTER_PATH && \
    adduser -D -h $IPFS_CLUSTER_PATH -u 1000 -G users ipfs && \
    chown ipfs:users $IPFS_CLUSTER_PATH

# Create mount points for `ipfs mount` command
RUN mkdir /ipfs /ipns \
  && chown ipfs:users /ipfs /ipns

# Expose the fs-repo as a volume.
# start_ipfs initializes an fs-repo if none is mounted.
# Important this happens after the USER directive so permission are correct.
VOLUME $IPFS_PATH
VOLUME $IPFS_CLUSTER_PATH

# The default logging level
ENV IPFS_LOGGING ""

# This just makes sure that:
# 1. There's an fs-repo, and initializes one if there isn't.
# 2. The API and Gateway are accessible from outside the container.
#ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start_ipfs"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]

# Execute the daemon subcommand by default
CMD ["daemon", "--migrate=true"]