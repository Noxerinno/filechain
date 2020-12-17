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

export SWARMKEY=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' ../mix/swarm.key)


export CLUSTER_SECRET=$(jq '.ClusterSecret' ../mix/config)
CLUSTER_SECRET=${CLUSTER_SECRET#"\""}
CLUSTER_SECRET=${CLUSTER_SECRET%"\""}

docker-compose up -d

IPFS_CONT_ID=$(docker ps -aqf "name=client_ipfs_1")
IPFS_CLUSTER_CONT_ID=$(docker ps -aqf "name=client_ipfs-cluster_1")
IPFS_CONT_ID_ADMIN=$(docker ps -aqf "name=admin_ipfs_1")
IPFS_CLUSTER_CONT_ID_ADMIN=$(docker ps -aqf "name=admin_ipfs-cluster_1")

ADMINIP=$(jq '.AdminIpAddress' ../mix/config)
ADMINIP=${ADMINIP#"\""}
ADMINIP=${ADMINIP%"\""}

ADMINID=$(jq '.IpfsId' ../mix/config)
ADMINID=${ADMINID#"\""}
ADMINID=${ADMINID%"\""}

PEERID=$(jq '.ClusterPeerId' ../mix/config)
PEERID=${PEERID#"\""}
PEERID=${PEERID%"\""}


echo "$IPFS_CONT_ID and $IPFS_CLUSTER_CONT_ID are starting..."
sleep 14

echo "Setting API Access Control"
docker exec -it $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://0.0.0.0:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
docker exec -it $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'

# Initiate private network

echo "Deleting default bootstrap"
docker exec -it $IPFS_CONT_ID ipfs bootstrap rm --all

echo "Adding admin node to bootstrap"
docker exec $IPFS_CONT_ID ipfs bootstrap add /ip4/"$ADMINIP"/tcp/4001/ipfs/$ADMINID

echo "Restarting IPFS container"
docker exec -it $IPFS_CONT_ID pkill ipfs
echo "Done with setting private network"

# IPFS Cluster
echo "Setting service.json"
IPADDR=$(docker exec -it $IPFS_CONT_ID ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo $IPADDR

docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/service.json ./service.json 
jq --arg IPADDR "$IPADDR" '.ipfs_connector.ipfshttp.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ./service.json  > tmp && mv tmp ./service.json
jq --arg IPADDR "$IPADDR" '.api.ipfsproxy.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ./service.json  > tmp && mv tmp ./service.json
docker cp ./service.json admin_ipfs-cluster_1:/data/ipfs-cluster/service.json
rm ./service.json

echo "Restarting IPFS Cluster container"
docker exec -it $IPFS_CLUSTER_CONT_ID pkill ipfs

