#!/bin/bash

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


# Initiate private network
# generate swarm file
FILECHAIN_ROOT=$(git rev-parse --show-toplevel)
IPFS_ADMIN_DIR=$FILECHAIN_ROOT/src/ipfs/admin

export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')

# #Swarkey's generator container build
# echo "Building swarmkey container..."
# docker build -t ipfs-setup $IPFS_ADMIN_DIR/ipfs-setup-image/ 1>/dev/null 2>/dev/null

#Starting IPFS setup container
chmod u+x -R $IPFS_ADMIN_DIR/ipfs-setup-image/assets/
docker-compose -f $IPFS_ADMIN_DIR/docker-compose.yml up -d ipfs-setup
IPFS_SETUP_CONT_ID=$(docker ps -aqf "name=^admin_ipfs-setup_1$")

#Generating swarmkey
docker exec -it $IPFS_SETUP_CONT_ID sh -c "/scripts/gen-key.sh"
cp $IPFS_ADMIN_DIR/data/swarmkey/swarm.key $FILECHAIN_ROOT/src/ipfs/mix/swarm.key
docker exec -it $IPFS_SETUP_CONT_ID sh -c "rm /swarmkey/key/swarm.key"
export SWARMKEY=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' $FILECHAIN_ROOT/src/ipfs/mix/swarm.key)
#echo $SWARMKEY
echo "Key generated and stored in swarm.key"

docker-compose -f $IPFS_ADMIN_DIR/docker-compose.yml up -d ipfs ipfs-cluster

#Retreive containers ID
IPFS_CONT_ID=$(docker ps -aqf "name=^admin_ipfs$")
IPFS_CLUSTER_CONT_ID=$(docker ps -aqf "name=^admin_cluster$")
echo "Containers $IPFS_SETUP_CONT_ID, $IPFS_CONT_ID and $IPFS_CLUSTER_CONT_ID are starting..."


#Checking IPFS container status
IPFS_IS_UP=$(docker exec $IPFS_CONT_ID ls /data/ipfs | grep api)
WAITING="Waiting for IPFS to start"
while [ "$IPFS_IS_UP" != "api" ]
do
    sleep 0.5
    echo -ne $WAITING'\r'
    WAITING+='.'
    IPFS_IS_UP=$(docker exec $IPFS_CONT_ID ls /data/ipfs | grep api)
done
echo -ne '\n'

echo "Ready!"
echo "Setting API Access Control"
docker exec $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://0.0.0.0:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
docker exec $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'

set bootstrap to admin node only
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

#Shutting down IPFS setup container
docker container stop $IPFS_SETUP_CONT_ID
docker container rm $IPFS_SETUP_CONT_ID


# IPFS Cluster

#Starting IPFS Cluster
chmod u+x -R $IPFS_ADMIN_DIR/ipfs-cluster-setup-image/assets/
docker-compose -f $IPFS_ADMIN_DIR/docker-compose.yml up -d ipfs-cluster-setup
IPFS_CLUSTER_SETUP_CONT_ID=$(docker ps -aqf "name=admin_ipfs-cluster-setup_1")

#Modifying service.json with jq on the setup container
echo "Setting service.json"
#docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/service.json $IPFS_ADMIN_DIR/data/config-files/service.json 
#chown root:root $IPFS_ADMIN_DIR/data/ipfs-cluster/service.json
#cp $IPFS_ADMIN_DIR/data/ipfs-cluster/service.json $IPFS_ADMIN_DIR/data/config-files/service.json

docker exec -it $IPFS_CLUSTER_CONT_ID sh -c 'mv /data/ipfs-cluster/service.json /config-files/'
# docker exec -it $IPFS_SETUP_CONT_ID sh -c "export IPADDR=$IPADDR"
docker exec -it $IPFS_CLUSTER_SETUP_CONT_ID sh -c "/scripts/jq-service.sh"
# docker exec -it $IPFS_CLUSTER_CONT_ID sh -c 'mv /config-files/ /data/ipfs-cluster/service.json '
# docker exec -it $IPFS_CLUSTER_CONT_ID sh -c 'rm -fd /config-files/'

#docker cp $IPFS_ADMIN_DIR/data/config-files/service.json admin_ipfs-cluster_1:/data/ipfs-cluster/service.json
#rm $IPFS_ADMIN_DIR/data/config-files/service.json


#docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/identity.json $IPFS_ADMIN_DIR/data/config-files/identity.json 
# cp $IPFS_ADMIN_DIR/data/ipfs-cluster/identity.json  $IPFS_ADMIN_DIR/data/config-files/identity.json 
# PEERID=$(cat $IPFS_ADMIN_DIR/data/config-files/identity.json | jq '.id')
# PEERID=$(echo $PEERID | cut -d '"' -f 2)
# #rm $IPFS_ADMIN_DIR/data/config-files/identity.json

# docker exec -it $IPFS_SETUP_CONT_ID sh -c "/scripts/jq-config.sh"

# echo "Restarting IPFS Cluster container"
# docker exec -it $IPFS_CLUSTER_CONT_ID pkill ipfs

#Shutting down IPFS setup container
docker container stop $IPFS_CLUSTER_SETUP_CONT_ID
docker container rm $IPFS_CLUSTER_SETUP_CONT_ID

# From Johan

# # echo "Setting service.json"
# # docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/service.json $IPFS_ADMIN_DIR/service.json 
# # jq --arg IPADDR "$IPADDR" '.ipfs_connector.ipfshttp.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' $IPFS_ADMIN_DIR/service.json  > tmp && mv tmp $IPFS_ADMIN_DIR/service.json
# # jq --arg IPADDR "$IPADDR" '.api.ipfsproxy.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' $IPFS_ADMIN_DIR/service.json  > tmp && mv tmp $IPFS_ADMIN_DIR/service.json
# # docker cp $IPFS_ADMIN_DIR/service.json admin_ipfs-cluster_1:/data/ipfs-cluster/service.json
# # rm $IPFS_ADMIN_DIR/service.json

# docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/identity.json $IPFS_ADMIN_DIR/identity.json 
# PEERID=$(cat $IPFS_ADMIN_DIR/identity.json | jq '.id')
# PEERID=$(echo $PEERID | cut -d '"' -f 2)
# rm $IPFS_ADMIN_DIR/identity.json

# jq -n '{"IpfsId": "","AdminIpAddress": "","SwarmKey":"","ClusterSecret": "","ClusterPeerId": ""}' > $FILECHAIN_ROOT/src/ipfs/mix/config
# jq --arg IPADDR "$IPADDR" '.AdminIpAddress=$IPADDR' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
# jq --arg SWARM "$SWARMKEY" '.SwarmKey=$SWARM' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
# jq --arg NODEID "$NODEID" '.IpfsId=$NODEID' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
# jq --arg CLUSTER_SECRET "$CLUSTER_SECRET" '.ClusterSecret=$CLUSTER_SECRET' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config
# jq --arg PEERID "$PEERID" '.ClusterPeerId=$PEERID' $FILECHAIN_ROOT/src/ipfs/mix/config > tmp && mv tmp $FILECHAIN_ROOT/src/ipfs/mix/config

# echo "Restarting IPFS Cluster container"
# docker exec -it $IPFS_CLUSTER_CONT_ID pkill ipfs