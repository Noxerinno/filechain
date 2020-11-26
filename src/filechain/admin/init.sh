#!/bin/bash

IPFS_CONT_ID=$(docker ps -aqf "name=admin_ipfs_1")
IPFS_CLUSTER_CONT_ID=$(docker ps -aqf "name=admin_ipfs-cluster_1")

echo $IPFS_CONT_ID 

docker exec -it $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '[\"http://0.0.0.0:5001\", \"http://localhost:3000\", \"http://127.0.0.1:5001\", \"https://webui.ipfs.io\"]'
docker exec -it $IPFS_CONT_ID ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '[\"PUT\", \"POST\"]'