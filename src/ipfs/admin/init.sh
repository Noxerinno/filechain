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

# Generate swarm file
FILECHAIN_ROOT=$(git rev-parse --show-toplevel)
IPFS_ADMIN_DIR=$FILECHAIN_ROOT/src/ipfs/admin

export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')

#Setup container build
echo "Building custom images..."
docker build -t ipfs-setup $IPFS_ADMIN_DIR/ipfs-setup-image/ 1>/dev/null 2>/dev/null
docker build -t ipfs-cluster-setup $IPFS_ADMIN_DIR/ipfs-cluster-setup-image/ 1>/dev/null 2>/dev/null

#Starting IPFS setup container
chmod u+x -R $IPFS_ADMIN_DIR/ipfs-setup-image/assets/
docker build -t ipfs-setup $IPFS_ADMIN_DIR/ipfs-setup-image/ 1>/dev/null 2>/dev/null
docker-compose -f $IPFS_ADMIN_DIR/docker-compose.yml up -d ipfs-setup 1>/dev/null 2>/dev/null
IPFS_SETUP_CONT_ID=$(docker ps -aqf "name=^admin_ipfs_setup$") 1>/dev/null 2>/dev/null

#Generating swarmkey
docker exec -it $IPFS_SETUP_CONT_ID sh -c "/scripts/gen-key.sh" 1>/dev/null 2>/dev/null
docker exec -it $IPFS_SETUP_CONT_ID sh -c "cp /swarmkey/key/swarm.key /jq/config-files/" 1>/dev/null 2>/dev/null
#cp $IPFS_ADMIN_DIR/data/swarmkey/swarm.key $FILECHAIN_ROOT/src/ipfs/mix/swarm.key
docker exec -it $IPFS_SETUP_CONT_ID sh -c "rm /swarmkey/key/swarm.key" 1>/dev/null 2>/dev/null
export SWARMKEY=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' $IPFS_ADMIN_DIR/data/config-files/swarm.key)
#echo $SWARMKEY
echo "Key generated and stored in swarm.key"

docker-compose -f $IPFS_ADMIN_DIR/docker-compose.yml up -d ipfs ipfs-cluster 1>/dev/null 2>/dev/null

#Retreive containers ID
IPFS_CONT_ID=$(docker ps -aqf "name=^admin_ipfs$") 1>/dev/null 2>/dev/null
IPFS_CLUSTER_CONT_ID=$(docker ps -aqf "name=^admin_cluster$") 1>/dev/null 2>/dev/null
echo "Containers $IPFS_SETUP_CONT_ID, $IPFS_CONT_ID and $IPFS_CLUSTER_CONT_ID are starting..."


#Checking IPFS container status
IPFS_IS_UP=$(docker exec $IPFS_CONT_ID ls /data/ipfs | grep api) 1>/dev/null 2>/dev/null
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

#Set bootstrap to admin node only
echo "Deleting default bootstrap"
docker exec -it $IPFS_CONT_ID ipfs bootstrap rm --all 1>/dev/null 2>/dev/null

echo "Adding admin node to bootstrap"
export IPADDR=$(docker exec -it $IPFS_CONT_ID ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p') 1>/dev/null 2>/dev/null
# echo $IPADDR
export NODEID=$(docker exec -it $IPFS_CONT_ID ipfs config --json Identity.PeerID | tr -d '\r') 1>/dev/null 2>/dev/null
# echo $NODEID
docker exec $IPFS_CONT_ID ipfs bootstrap add /ip4/"$IPADDR"/tcp/4001/ipfs/$NODEID 1>/dev/null 2>/dev/null
# force private network (TODO: set this value in .bashrc file ?)

echo "Restarting IPFS container"
docker exec -it $IPFS_CONT_ID pkill ipfs 1>/dev/null 2>/dev/null
echo "Done with setting private network"




# IPFS Cluster

# docker exec -it $IPFS_SETUP_CONT_ID sh -c 'whoami'
export PEERID=$(docker exec -it $IPFS_SETUP_CONT_ID sh -c "cat /jq/ipfs-files/identity.json | /jq/jq \".id\" | cut -d '\"' -f 2") 1>/dev/null 2>/dev/null
docker exec -it $IPFS_SETUP_CONT_ID sh -c "cp /jq/ipfs-files/identity.json /jq/config-files/ && " 1>/dev/null 2>/dev/null

#Shutting down IPFS setup container
docker container stop $IPFS_SETUP_CONT_ID 1>/dev/null 2>/dev/null
docker container rm $IPFS_SETUP_CONT_ID 1>/dev/null 2>/dev/null


#Starting IPFS Cluster
chmod u+x -R $IPFS_ADMIN_DIR/ipfs-cluster-setup-image/assets/
docker-compose -f $IPFS_ADMIN_DIR/docker-compose.yml up -d ipfs-cluster-setup 1>/dev/null 2>/dev/null
IPFS_CLUSTER_SETUP_CONT_ID=$(docker ps -aqf "name=admin_cluster_setup") 1>/dev/null 2>/dev/null
docker exec -it $IPFS_CLUSTER_SETUP_CONT_ID sh -c '/scripts/jq-config.sh' 1>/dev/null 2>/dev/null
echo "Config file created"

#Shutting down IPFS setup container
docker container stop $IPFS_CLUSTER_SETUP_CONT_ID 1>/dev/null 2>/dev/null
docker container rm $IPFS_CLUSTER_SETUP_CONT_ID 1>/dev/null 2>/dev/null

echo "Restarting IPFS Cluster container"
docker exec -it $IPFS_CLUSTER_CONT_ID pkill ipfs 1>/dev/null 2>/dev/null


json="{\\\\\\\"IpfsId\\\\\\\":\\\\\\\"${NODEID}\\\\\\\",\\\\\\\"AdminIpAddress\\\\\\\":\\\\\\\"${IPADDR}\\\\\\\",\\\\\\\"SwarmKey\\\\\\\":\\\\\\\"${SWARMKEY}\\\\\\\",\\\\\\\"ClusterSecret\\\\\\\":\\\\\\\"${CLUSTER_SECRET}\\\\\\\",\\\\\\\"ClusterPeerId\\\\\\\":\\\\\\\"${PEERID}\\\\\\\"}"
docker exec -it cli sh -c './scripts/05-invokeCreateCCadminConfigOrg1.sh ' ${json}
