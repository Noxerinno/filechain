# Copyright [2020] [Frantz Darbon, Gilles Seghaier, Johan Tombre, Frédéric Vaz]

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ==============================================================================

export ORDERER_CA_1=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/orderers/orderer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com.crt.pem
export ORDERER_CA_2=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/orderers/orderer0.org2.example.com/msp/tlscacerts/tlsca.org2.example.com.crt.pem

export FABRIC_CFG_PATH=$PWD
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com.crt.pem
export CHAINCODE_SOURCES_PATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/chaincodes/chaincode_example02

###########################
# Installing in peer Org1 #
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=${IP_PEER_ORG1}:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
CHANNEL_NAME=channel1
CORE_PEER_TLS_ENABLED=false
ORDERER_SYSCHAN_ID=syschain

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=${IP_PEER_ORG2}:8051
export CORE_PEER_LOCALMSPID="Org2MSP"

read -p "Press any key to continue (invoke Create org1) ..."
peer chaincode invoke -n simple-contract -c '{"Args":["Create", "KEY_2", "VALUE_1"]}' -C channel1 -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA_1 --peerAddresses ${IP_PEER_ORG1}:7051
read -p "Press any key to continue (invoke Create org2) ..."
peer chaincode invoke -n simple-contract -c '{"Args":["Create", "KEY_2", "VALUE_1"]}' -C channel1 -o orderer0.org2.example.com:7050 --cafile $ORDERER_CA_2 --peerAddresses ${IP_PEER_ORG2}:8051
read -p "Press any key to continue (invoke Update) ..."
peer chaincode query -n simple-contract -c '{"Args":["Read", "KEY_2"]}' -C channel1
#peer chaincode invoke -n "simple-contract" -c '{"Args":["Update", "KEY_1", "VALUE_2"]}' -C channel1 -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA --peerAddresses ${IP_PEER_ORG1}:7051 --peerAddresses ${IP_PEER_ORG2}:8051
