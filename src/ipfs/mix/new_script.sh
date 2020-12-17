# Copyright [2020] [Frantz Darbon, Gilles Seghaier, Johan Tombre, Frédéric Vaz]

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ==============================================================================



#!/bin/bash

CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
echo $CLUSTER_SECRET
docker-compose up -d

IPFS_CONT_ID=$(docker ps -aqf "name=mix_client-ipfs_1")
IPFS_CLUSTER_CONT_ID=$(docker ps -aqf "name=mix_client-ipfs-cluster_1")
IPFS_CONT_ID_ADMIN=$(docker ps -aqf "name=mix_admin-ipfs_1")
IPFS_CLUSTER_CONT_ID_ADMIN=$(docker ps -aqf "name=mix_admin-ipfs-cluster_1")

echo $IPFS_CONT_ID_ADMIN
echo $IPFS_CLUSTER_CONT_ID_ADMIN
sleep 10
docker exec -it $IPFS_CONT_ID_ADMIN ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '[\"http://0.0.0.0:5001\", \"http://localhost:3000\", \"http://127.0.0.1:5001\", \"https://webui.ipfs.io\"]'
docker exec -it $IPFS_CONT_ID_ADMIN ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '[\"PUT\", \"POST\"]'

docker exec -it $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '[\"http://0.0.0.0:5001\", \"http://localhost:3000\", \"http://127.0.0.1:5001\", \"https://webui.ipfs.io\"]'
docker exec -it $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '[\"PUT\", \"POST\"]'

# Initiate private network
# generate swarm file
./bin/ipfs-swarm-key-gen > swarm.key
echo "Key generated and stored in swarm.key"
docker cp ./swarm.key mix_admin-ipfs_1:/data/ipfs/
docker cp ./swarm.key mix_client-ipfs_1:/data/ipfs/

# set bootstrap to admin node only
docker exec -it $IPFS_CONT_ID_ADMIN ipfs bootstrap rm --all
docker exec -it $IPFS_CONT_ID ipfs bootstrap rm --all

# NODEID=$(docker exec -it ipfs id | jq '.ID')
IPADDR=$(docker exec -it $IPFS_CONT_ID_ADMIN ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo $IPADDR
NODEID=$(docker exec -it $IPFS_CONT_ID_ADMIN ipfs config --json Identity.PeerID | tr -d '\r')
echo $NODEID
docker exec -it $IPFS_CONT_ID_ADMIN ipfs bootstrap add /ip4/"$IPADDR"/tcp/4001/ipfs/$NODEID
docker exec -it $IPFS_CONT_ID ipfs bootstrap add /ip4/"$IPADDR"/tcp/4001/ipfs/$NODEID
# force private network (TODO: set this value in .bashrc file ?)
echo "Done with setting private network"

# IPFS Cluster

# docker exec $IPFS_CLUSTER_CONT_ID /bin/sh -c 'export CLUSTER_SECRET='$CLUSTER_SECRET)
