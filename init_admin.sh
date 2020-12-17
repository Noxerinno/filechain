Copyright [2020] [Frantz Darbon, Gilles Seghaier, Johan Tombre, Frédéric Vaz]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

==============================================================================



#! bin/bash

# IPFS
jq -n '{"IpfsId": "","AdminIpAddress": "","SwarmKey":"","ClusterSecret": "","ClusterPeerId": ""}' > config

# init IPFS node
echo "IPFS initialisation"
ipfs init

# get ipfs node id and store it in a json file
echo "Getting Node ID..."
NODEID=$(ipfs id | jq '.ID')
NODEID=$(echo $NODEID | cut -d '"' -f 2)
jq --arg NODEID "$NODEID" '.IpfsId=$NODEID' config > tmp && mv tmp config

# get ip address for this docker node and store it in json file
IPADDR=$(getent hosts `hostname` | awk '{print $1}')
jq --arg IPADDR "$IPADDR" '.AdminIpAddress=$IPADDR' config > tmp && mv tmp config

# generate swarm file
ipfs-swarm-key-gen > ~/.ipfs/swarm.key
jq --arg SWARM "$(cat ~/.ipfs/swarm.key)" '.SwarmKey=$SWARM' config > tmp && mv tmp config

# set bootstrap to admin node only
ipfs bootstrap rm --all
ipfs bootstrap add /ip4/$IPADDR/tcp/4001/ipfs/$NODEID

# force private network
export LIBP2P_FORCE_PNET=1

# set node ip address in .ipfs/config file
jq --arg IPADDR "$IPADDR" '.Addresses.API="/ip4/"+$IPADDR+"/tcp/5001"' ~/.ipfs/config  > tmp && mv tmp ~/.ipfs/config
jq --arg IPADDR "$IPADDR" '.Addresses.Gateway="/ip4/"+$IPADDR+"/tcp/8080"' ~/.ipfs/config  > tmp && mv tmp ~/.ipfs/config

# start ipfs daemon
systemctl start ipfs


# IPFS CLUSTER

# init cluster secret variable
CLUSTERSECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
jq --arg CLUSTERSECRET "$CLUSTERSECRET" '.ClusterSecret=$CLUSTERSECRET' config > tmp && mv tmp config
echo '\n# Cluster IPFS Secret\nexport CLUSTER_SECRET='$CLUSTERSECRET >> ~/.bashrc

# init ipfs cluster
ipfs-cluster-service init

# change ip address in ~/.ipfs-cluster/service.json
echo "edit IP in service file"
jq --arg IPADDR "$IPADDR" '.ipfs_connector.ipfshttp.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ~/.ipfs-cluster/service.json  > tmp && mv tmp ~/.ipfs-cluster/service.json
jq --arg IPADDR "$IPADDR" '.api.ipfsproxy.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ~/.ipfs-cluster/service.json  > tmp && mv tmp ~/.ipfs-cluster/service.json

# export peer id from cluster to local machine
echo "PEER ID to local machine"
PEERID=$(cat ~/.ipfs-cluster/identity.json | jq '.id')
PEERID=$(echo $PEERID | cut -d '"' -f 2)
jq --arg PEERID "$PEERID" '.ClusterPeerId=$PEERID' config > tmp && mv tmp config

# intier le bootstrap IPFS Cluster
#echo "Init Cluster"
#ipfs-cluster-service daemon --bootstrap /ip4/$IPADDR/tcp/9096/ipfs/$PEERID

# lancer le daemon
systemctl start ipfs-cluster
echo "Admin initialisation DONE !"