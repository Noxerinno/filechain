#!/bin/bash
#SPDX-License-Identifier: Apache-2.0
#Author: kehm

#Sends create channel request to orderer

set -e
export CHANNEL_NAME=mychannel
export ORDERER_NAME=orderer0.org1.example.com
echo "Create channel request:Start"
peer channel create -o $ORDERER_NAME:7050 -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/$ORDERER_NAME/msp/tlscacerts/tlsca.org1.example.com-cert.pem
echo "Create channel request:Done"
