#!/bin/bash
#SPDX-License-Identifier: Apache-2.0
#Author: kehm

#Defines anchor peers for each organization

set -e
export CHANNEL_NAME=channel
export ORDERER_NAME=orderer0.org1.example.com
export ORG_NAME=org1.example.com
export PEER_NAME=peer0
export MSPID="Org1MSP"
export PANCHORS=Org1MSPanchors
echo "Setting anchor peer for $ORG_NAME:$PEER_NAME"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME/users/Admin@$ORG_NAME/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME:7051 CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME/peers/$PEER_NAME.$ORG_NAME/tls/ca.crt
peer channel update -o $ORDERER_NAME:7050 -c $CHANNEL_NAME -f ./channel-artifacts/$PANCHORS.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/$ORDERER_NAME/msp/tlscacerts/tlsca.org1.example.com-cert.pem
export ORG_NAME=org2.example.com
export PEER_NAME=peer0
export MSPID="Org2MSP"
export PANCHORS=Org2MSPanchors
echo "Setting anchor peer for $ORG_NAME:$PEER_NAME"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME/users/Admin@$ORG_NAME/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME:7051 CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME/peers/$PEER_NAME.$ORG_NAME/tls/ca.crt
peer channel update -o $ORDERER_NAME:7050 -c $CHANNEL_NAME -f ./channel-artifacts/$PANCHORS.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/$ORDERER_NAME/msp/tlscacerts/tlsca.org1.example.com-cert.pem
