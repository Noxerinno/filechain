#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e
# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
export ORG1_CA_KEYFILE=`find crypto-config/peerOrganizations/org1.example.com/ca/*_sk -printf "%f\n"`
export ORG2_CA_KEYFILE=`find crypto-config/peerOrganizations/org2.example.com/ca/*_sk -printf "%f\n"`
starttime=$(date +%s)
LANGUAGE=${1:-"node"}
# clean the keystore
rm -rf ./hfc-key-store
echo "Putting down network"
docker-compose -f docker-compose.yaml down
echo "Creating network"
docker-compose -f docker-compose.yaml up -d cli0 orderer0.org1.example.com orderer0.org2.example.com peer0.org1.example.com peer0.org2.example.com
# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export 
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}
echo "Creating docker containers:Done"
echo "Waiting $1s for orderers to get ready"
echo "Send create channel request:Start"
docker exec -i cli0 bash < ./sample-setup/create-channel-request.sh  #create channel
echo "Send create channel request:Done"
echo "Adding peers to channel:Start"
docker exec -i cli0 bash < sample-setup/join-peers-to-channel.sh  #add peers to channel
echo "Adding peers to channel:Done"
echo "Define anchor peers:Start"
docker exec -i cli0 bash < sample-setup/define-anchor-peers.sh  #define anchor peers
echo "Define anchor peers:Done"

