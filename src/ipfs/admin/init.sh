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

# Initiate private network
# generate swarm file

FILECHAIN_ROOT=$(git rev-parse --show-toplevel)
IPFS_ADMIN_DIR=$FILECHAIN_ROOT/src/ipfs/admin

# export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')

# $FILECHAIN_ROOT/src/ipfs/mix/bin/ipfs-swarm-key-gen > $FILECHAIN_ROOT/src/ipfs/mix/swarm.key
# export SWARMKEY=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' $FILECHAIN_ROOT/src/ipfs/mix/swarm.key)
# echo $SWARMKEY
# echo "Key generated and stored in swarm.key"


echo "Building swarmkey container..."
docker build -t ipfs-swarmkey $FILECHAIN_ROOT/src/ipfs/admin/setup-image/ 1>/dev/null
#docker-compose -f  ipfs-swarmkey

docker-compose -f $FILECHAIN_ROOT/src/ipfs/admin/docker-compose.yml up -d

IPFS_CONT_ID=$(docker ps -aqf "name=admin_ipfs_1")
IPFS_CLUSTER_CONT_ID=$(docker ps -aqf "name=admin_ipfs-cluster_1")
IPFS_IS_UP=$(docker exec $IPFS_CONT_ID ls /data/ipfs | grep api)
echo "Containers $IPFS_CONT_ID and $IPFS_CLUSTER_CONT_ID are starting..."

WAITING="Waiting for IPFS to start"
while [ "$IPFS_IS_UP" != "api" ]
do
    echo -ne $WAITING'\r'
    WAITING+='.'
    IPFS_IS_UP=$(docker exec $IPFS_CONT_ID ls /data/ipfs | grep api)
    sleep 0.5
done
echo -ne '\n'

echo "Ready!"
echo "Setting API Access Control"
docker exec $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://0.0.0.0:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
docker exec $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'

# set bootstrap to admin node only
echo "Deleting default bootstrap"
docker exec -it $IPFS_CONT_ID ipfs bootstrap rm --all

echo "Adding admin node to bootstrap"
IPADDR=$(docker exec -it $IPFS_CONT_ID ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo $IPADDR
NODEID=$(docker exec -it $IPFS_CONT_ID ipfs config --json Identity.PeerID | tr -d '\r')
echo $NODEID
docker exec $IPFS_CONT_ID ipfs bootstrap add /ip4/"$IPADDR"/tcp/4001/ipfs/$NODEID
# force private network (TODO: set this value in .bashrc file ?)

echo "Restarting IPFS container"
docker exec -it $IPFS_CONT_ID pkill ipfs
echo "Done with setting private network"

# IPFS Cluster

echo "Setting service.json"
docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/service.json $IPFS_ADMIN_DIR/service.json 
jq --arg IPADDR "$IPADDR" '.ipfs_connector.ipfshttp.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' $IPFS_ADMIN_DIR/service.json  > tmp && mv tmp $IPFS_ADMIN_DIR/service.json
jq --arg IPADDR "$IPADDR" '.api.ipfsproxy.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' $IPFS_ADMIN_DIR/service.json  > tmp && mv tmp $IPFS_ADMIN_DIR/service.json
docker cp $IPFS_ADMIN_DIR/service.json admin_ipfs-cluster_1:/data/ipfs-cluster/service.json
rm $IPFS_ADMIN_DIR/service.json

docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/identity.json $IPFS_ADMIN_DIR/identity.json 
PEERID=$(cat $IPFS_ADMIN_DIR/identity.json | jq '.id')
PEERID=$(echo $PEERID | cut -d '"' -f 2)
rm $IPFS_ADMIN_DIR/identity.json

jq -n '{"IpfsId": "","AdminIpAddress": "","SwarmKey":"","ClusterSecret": "","ClusterPeerId": ""}' > $FILECHAIN_ROOT/src/ipfs/mix/config
jq --arg IPADDR "$IPADDR" '.AdminIpAddress=$IPADDR' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
jq --arg SWARM "$SWARMKEY" '.SwarmKey=$SWARM' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
jq --arg NODEID "$NODEID" '.IpfsId=$NODEID' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
jq --arg CLUSTER_SECRET "$CLUSTER_SECRET" '.ClusterSecret=$CLUSTER_SECRET' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
jq --arg PEERID "$PEERID" '.ClusterPeerId=$PEERID' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config

echo "Restarting IPFS Cluster container"
docker exec -it $IPFS_CLUSTER_CONT_ID pkill ipfs
