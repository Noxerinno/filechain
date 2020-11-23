#!/bin/bash
#SPDX-License-Identifier: Apache-2.0
#Author: kehm

#Installs chaincode on peers and instantiates it on channel

export CHANNEL_NAME=providerschannel
export CHAINCODE1_FOLDER_NAME=IncentiveMechanism
export CHAINCODE1_NAME=IncentiveMechanism
export CHAINCODE2_FOLDER_NAME=SummaryContract
export CHAINCODE2_NAME=SummaryContract
export CHAINCODE3_FOLDER_NAME=RecordRelationshipContract
export CHAINCODE3_NAME=RecordRelationshipContract

echo "Install chaincode on peers:Start"
export PEER_NAME=peer0
export ORG_NAME=hospital1
export MSPID="Hospital1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/users/Admin@$ORG_NAME.example.com/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME.example.com:7051
CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/peers/$PEER_NAME.$ORG_NAME.example.com/tls/ca.crt
peer chaincode install -n $CHAINCODE1_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE1_FOLDER_NAME
peer chaincode install -n $CHAINCODE2_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE2_FOLDER_NAME
peer chaincode install -n $CHAINCODE3_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE3_FOLDER_NAME

export PEER_NAME=peer1
export ORG_NAME=hospital1
export MSPID="Hospital1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/users/Admin@$ORG_NAME.example.com/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME.example.com:7051
CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/peers/$PEER_NAME.$ORG_NAME.example.com/tls/ca.crt
peer chaincode install -n $CHAINCODE1_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE1_FOLDER_NAME
peer chaincode install -n $CHAINCODE2_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE2_FOLDER_NAME
peer chaincode install -n $CHAINCODE3_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE3_FOLDER_NAME

export PEER_NAME=peer0
export ORG_NAME=pharmacy1
export MSPID="Pharmacy1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/users/Admin@$ORG_NAME.example.com/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME.example.com:7051
CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/peers/$PEER_NAME.$ORG_NAME.example.com/tls/ca.crt
peer chaincode install -n $CHAINCODE1_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE1_FOLDER_NAME
peer chaincode install -n $CHAINCODE2_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE2_FOLDER_NAME
peer chaincode install -n $CHAINCODE3_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE3_FOLDER_NAME

export PEER_NAME=peer1
export ORG_NAME=pharmacy1
export MSPID="Pharmacy1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/users/Admin@$ORG_NAME.example.com/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME.example.com:7051
CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/peers/$PEER_NAME.$ORG_NAME.example.com/tls/ca.crt
peer chaincode install -n $CHAINCODE1_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE1_FOLDER_NAME
peer chaincode install -n $CHAINCODE2_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE2_FOLDER_NAME
peer chaincode install -n $CHAINCODE3_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE3_FOLDER_NAME

export PEER_NAME=peer0
export ORG_NAME=practitioner1
export MSPID="Practitioner1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/users/Admin@$ORG_NAME.example.com/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME.example.com:7051
CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/peers/$PEER_NAME.$ORG_NAME.example.com/tls/ca.crt
peer chaincode install -n $CHAINCODE1_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE1_FOLDER_NAME
peer chaincode install -n $CHAINCODE2_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE2_FOLDER_NAME
peer chaincode install -n $CHAINCODE3_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE3_FOLDER_NAME

export PEER_NAME=peer1
export ORG_NAME=practitioner1
export MSPID="Practitioner1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/users/Admin@$ORG_NAME.example.com/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME.example.com:7051
CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/peers/$PEER_NAME.$ORG_NAME.example.com/tls/ca.crt
peer chaincode install -n $CHAINCODE1_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE1_FOLDER_NAME
peer chaincode install -n $CHAINCODE2_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE2_FOLDER_NAME
peer chaincode install -n $CHAINCODE3_NAME -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/$CHAINCODE3_FOLDER_NAME

echo "Install chaincode on peers:Done"
echo "Instantiate chaincode on channel:Start"
export ORDERER=orderer0.hospital1.example.com
export PEER_NAME=peer0
export ORG_NAME=hospital1
export MSPID="Hospital1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/users/Admin@$ORG_NAME.example.com/msp
CORE_PEER_ADDRESS=$PEER_NAME.$ORG_NAME.example.com:7051
CORE_PEER_LOCALMSPID=$MSPID
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$ORG_NAME.example.com/peers/$PEER_NAME.$ORG_NAME.example.com/tls/ca.crt
peer chaincode instantiate -o $ORDERER:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hospital1.example.com/peers/$ORDERER/msp/tlscacerts/tlsca.hospital1.example.com-cert.pem -C $CHANNEL_NAME -n $CHAINCODE1_NAME -l java -v 1.0 -c '{"Args":["init", "hospital1", "pharmacy1", "practitioner1", "120", "80", "50"]}' -P "OutOf(2, 'Hospital1MSP.peer', 'Pharmacy1MSP.peer', 'Practitioner1MSP.peer')"
peer chaincode instantiate -o $ORDERER:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hospital1.example.com/peers/$ORDERER/msp/tlscacerts/tlsca.hospital1.example.com-cert.pem -C $CHANNEL_NAME -n $CHAINCODE2_NAME -l java -v 1.0 -c '{"Args":["init"]}' -P "OutOf(2, 'Hospital1MSP.peer', 'Pharmacy1MSP.peer', 'Practitioner1MSP.peer')"
peer chaincode instantiate -o $ORDERER:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hospital1.example.com/peers/$ORDERER/msp/tlscacerts/tlsca.hospital1.example.com-cert.pem -C $CHANNEL_NAME -n $CHAINCODE3_NAME -l java -v 1.0 -c '{"Args":["init"]}' -P "OutOf(2, 'Hospital1MSP.peer', 'Pharmacy1MSP.peer', 'Practitioner1MSP.peer')"
echo "Instantiate chaincode on channel:Done"
