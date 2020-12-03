#! bin/bash

# init IPFS node
echo "IPFS initialisation"
ipfs init

# get ipfs node id and store it in a json file
echo "Getting Node ID..."
NODEID=$(ipfs id | jq '.ID')
NODEID=$(echo $NODEID | cut -d '"' -f 2)

# get ip address for this docker node and store it in json file
IPADDR=$(getent hosts `hostname` | awk '{print $1}')

# retrieve swarm.key from config
ADMINIP=$(jq '.AdminIpAddress' config)
ADMINIP=${ADMINIP#"\""}
ADMINIP=${ADMINIP%"\""}

ADMINID=$(jq '.IpfsId' config)
ADMINID=${ADMINID#"\""}
ADMINID=${ADMINID%"\""}

PEERID=$(jq '.ClusterPeerId' config)
PEERID=${PEERID#"\""}
PEERID=${PEERID%"\""}

TMPSWARM=$(jq '.SwarmKey' config)
TMPSWARM=${TMPSWARM#"\""}
TMPSWARM=${TMPSWARM%"\""}

echo $TMPSWARM > ~/.ipfs/swarm.key
# set bootstrap to admin node only
ipfs bootstrap rm --all
ipfs bootstrap add /ip4/$ADMINIP/tcp/4001/ipfs/$ADMINID

# force private network
export LIBP2P_FORCE_PNET=1

# set node ip address in .ipfs/config file
jq --arg IPADDR "$IPADDR" '.Addresses.API="/ip4/"+$IPADDR+"/tcp/5001"' ~/.ipfs/config  > tmp && mv tmp ~/.ipfs/config
jq --arg IPADDR "$IPADDR" '.Addresses.Gateway="/ip4/"+$IPADDR+"/tcp/8080"' ~/.ipfs/config  > tmp && mv tmp ~/.ipfs/config

# start ipfs daemon
systemctl start ipfs


# IPFS CLUSTER

# init cluster secret variable
CLUSTERSECRET=$(jq '.ClusterSecret' config)
CLUSTERSECRET=${CLUSTERSECRET#"\""}
CLUSTERSECRET=${CLUSTERSECRET%"\""}
echo '\n# Cluster IPFS Secret\nexport CLUSTER_SECRET='$CLUSTERSECRET >> ~/.bashrc
echo "Export temp CLUSTER_SECRET"
export CLUSTER_SECRET=$CLUSTERSECRET
# init ipfs cluster
ipfs-cluster-service init

# change ip address in ~/.ipfs-cluster/service.json
echo "edit IP in service file"
jq --arg IPADDR "$IPADDR" '.ipfs_connector.ipfshttp.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ~/.ipfs-cluster/service.json  > tmp && mv tmp ~/.ipfs-cluster/service.json
jq --arg IPADDR "$IPADDR" '.api.ipfsproxy.node_multiaddress="/ip4/"+$IPADDR+"/tcp/5001"' ~/.ipfs-cluster/service.json  > tmp && mv tmp ~/.ipfs-cluster/service.json

# intier le bootstrap IPFS Cluster
echo "Init Cluster"
ipfs-cluster-service daemon --bootstrap /ip4/$ADMINIP/tcp/9096/ipfs/$PEERID &

# lancer le daemon
echo "Node initialisation DONE !"