#!/bin/bash

# Initiate private network
# generate swarm file


export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')

../mix/bin/ipfs-swarm-key-gen > ../mix/swarm.key
export SWARMKEY=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' ../mix/swarm.key)
echo $SWARMKEY
echo "Key generated and stored in swarm.key"

docker-compose up -d
IPFS_CONT_ID=$(docker ps -aqf "name=admin_ipfs_1")
IPFS_CLUSTER_CONT_ID=$(docker ps -aqf "name=admin_ipfs-cluster_1")
echo "Containers $IPFS_CONT_ID and $IPFS_CLUSTER_CONT_ID are starting..."

sleep 10
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
docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/service.json ./service.json 
../mix/bin/jq --arg IPADDR "$IPADDR" '.ipfs_connector.ipfshttp.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ./service.json  > tmp && mv tmp ./service.json
../mix/bin/jq --arg IPADDR "$IPADDR" '.api.ipfsproxy.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ./service.json  > tmp && mv tmp ./service.json
docker cp ./service.json admin_ipfs-cluster_1:/data/ipfs-cluster/service.json
rm ./service.json

docker cp $IPFS_CLUSTER_CONT_ID:/data/ipfs-cluster/identity.json ./identity.json 
PEERID=$(cat ./identity.json | jq '.id')
PEERID=$(echo $PEERID | cut -d '"' -f 2)
rm ./identity.json

../mix/bin/jq -n '{"IpfsId": "","AdminIpAddress": "","SwarmKey":"","ClusterSecret": "","ClusterPeerId": ""}' > ../mix/config
../mix/bin/jq --arg IPADDR "$IPADDR" '.AdminIpAddress=$IPADDR' ../mix/config > tmp && mv tmp ../mix/config
../mix/bin/jq --arg SWARM "$SWARMKEY" '.SwarmKey=$SWARM' ../mix/config > tmp && mv tmp ../mix/config
../mix/bin/jq --arg NODEID "$NODEID" '.IpfsId=$NODEID' ../mix/config > tmp && mv tmp ../mix/config
../mix/bin/jq --arg CLUSTER_SECRET "$CLUSTER_SECRET" '.ClusterSecret=$CLUSTER_SECRET' ../mix/config > tmp && mv tmp ../mix/config
../mix/bin/jq --arg PEERID "$PEERID" '.ClusterPeerId=$PEERID' ../mix/config > tmp && mv tmp ../mix/config

echo "Restarting IPFS Cluster container"
docker exec -it $IPFS_CLUSTER_CONT_ID pkill ipfs
