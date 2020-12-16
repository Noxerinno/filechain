#!/bin/bash

# export PATH=$PWD/bin:$PATH
export FABRIC_CFG_PATH=${PWD}
echo "Genetating certs for ordering service"
cryptogen generate --config=./crypto-config.yaml

echo "Generate artifacts for channel"
mkdir -p channel-artifacts
configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID testchainid
configtxgen -profile Channel -outputCreateChannelTx ./channel-artifacts/channel1.tx -channelID channel1