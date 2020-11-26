#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
# SCRIPT FOR GENERATING CERTIFICATES AND ARTIFACTS
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=mychannel
# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*
# generate crypto material
echo "Generate crypto material"
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
echo "Failed to generate crypto material..."
exit 1
fi
mkdir channel-artifacts
# generate genesis block for orderer
echo "Generate genesis block for orderer"
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID orderer-system-channel
if [ "$?" -ne 0 ]; then
echo "Failed to generate orderer genesis block..."
exit 1
fi
# generate channel configuration transaction
echo "Generate channel configuration transaction"
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
echo "Failed to generate channel configuration transaction..."
exit 1
fi
# generate anchor peer transaction
echo "Generate anchor peer transaction Org1"
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
echo "Failed to generate anchor peer update for Org1MSP..."
exit 1
fi
# generate anchor peer transaction
echo "Generate anchor peer transaction Org2"
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
if [ "$?" -ne 0 ]; then
echo "Failed to generate anchor peer update for Org2MSP..."
exit 1
fi
