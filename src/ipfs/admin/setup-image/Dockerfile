FROM golang:alpine as build

RUN apk add --no-cache git
RUN go get github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen

FROM golang:alpine

COPY --from=build /go/bin/ipfs-swarm-key-gen /swarmkey/
RUN mkdir /jq/
RUN wget -O /jq/jq https://www.github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 1>/dev/null
RUN chmod u+x /jq/jq


# FROM golang:alpine

# ARG S3FS_VERSION=v1.86

# RUN apk --no-cache add \
#     ca-certificates \
#     build-base \
#     git \
#     alpine-sdk \
#     libcurl \
#     automake \
#     autoconf \
#     libxml2-dev \
#     libressl-dev \
#     fuse-dev \
#     curl-dev 
# WORKDIR /home/
# RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git
# WORKDIR s3fs-fuse  
# #RUN git checkout tags/v1.86
# RUN ls
# RUN ./autogen.sh
# RUN ./configure --prefix=/usr
# RUN make -j
# RUN make install

# # Specify URL and secrets. When using AWS_S3_SECRET_ACCESS_KEY_FILE, the secret
# # key will be read from that file itself, which helps passing further passwords
# # using Docker secrets. You can either specify the path to an authorisation
# # file, set environment variables with the key and the secret.
# ENV AWS_S3_URL=https://s3.amazonaws.com
# ENV AWS_S3_ACCESS_KEY_ID=
# ENV AWS_S3_SECRET_ACCESS_KEY=
# ENV AWS_S3_SECRET_ACCESS_KEY_FILE=
# ENV AWS_S3_AUTHFILE=
# ENV AWS_S3_BUCKET=heroku-polls-user

# # User and group ID of share owner
# ENV RUN_AS=
# ENV UID=0
# ENV GID=0

# # Location of directory where to mount the drive into the container.
# ENV AWS_S3_MOUNT=/opt/s3fs/bucket

# # s3fs tuning
# ENV S3FS_DEBUG=0
# ENV S3FS_ARGS=

# RUN mkdir /opt/s3fs
# RUN apk --no-cache add \
#       ca-certificates \
#       fuse \
#       libxml2 \
#       libcurl \
#       libgcc \
#       libstdc++ \
#       tini
# RUN s3fs --version

# # allow access to volume by different user to enable UIDs other than root when using volumes
# RUN echo user_allow_other >> /etc/fuse.conf

# COPY *.sh /usr/local/bin/

# WORKDIR /opt/s3fs



# # Following should match the AWS_S3_MOUNT environment variable.
# VOLUME [ "/opt/s3fs/bucket" ]

# # The default is to perform all system-level mounting as part of the entrypoint
# # to then have a command that will keep listing the files under the main share.
# # Listing the files will keep the share active and avoid that the remote server
# # closes the connection.
# ENTRYPOINT [ "tini", "-g", "--", "docker-entrypoint.sh" ]

# CMD [ "ls.sh" ]