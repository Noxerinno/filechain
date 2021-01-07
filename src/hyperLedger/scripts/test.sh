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

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/orderers/orderer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com.crt.pem

# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com.crt.pem

#Installing in peer Org1
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=${IP_PEER_ORG1}:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
CHANNEL_NAME=channel1
CORE_PEER_TLS_ENABLED=false
ORDERER_SYSCHAN_ID=syschain

peer lifecycle chaincode package simple-contract.tar.gz --path github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 --lang golang --label simple-contract_1.0
peer lifecycle chaincode install simple-contract.tar.gz
peer lifecycle chaincode queryinstalled
touch test.txt
peer lifecycle chaincode queryinstalled > text.txt
export PACKAGE_ID=$(cat text.txt | grep  "Package ID" | cut -d' ' -f3 | sed 's/.$//')
peer lifecycle chaincode approveformyorg -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA --channelID channel1 --name "simple-contract" --version 1.0 --package-id $PACKAGE_ID --sequence 1 --signature-policy "OR('Org1MSP.peer','Org2MSP.peer')"

#Installing in peer Org2
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=${IP_PEER_ORG2}:8051
export CORE_PEER_LOCALMSPID="Org2MSP"


peer lifecycle chaincode package simple-contract.tar.gz --path github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 --lang golang --label simple-contract_1.0
peer lifecycle chaincode install simple-contract.tar.gz
touch test.txt
peer lifecycle chaincode queryinstalled > text.txt
export PACKAGE_ID=$(cat text.txt | grep  "Package ID" | cut -d' ' -f3 | sed 's/.$//')

peer lifecycle chaincode approveformyorg -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA --channelID channel1 --name "simple-contract" --version 1.0 --package-id $PACKAGE_ID --sequence 1 --signature-policy "OR('Org1MSP.peer','Org2MSP.peer')"

peer lifecycle chaincode checkcommitreadiness --channelID channel1 --name "simple-contract" --version 1.0 --cafile $ORDERER_CA --output json --sequence 1 --signature-policy "OR('Org1MSP.peer','Org2MSP.peer')"

peer lifecycle chaincode commit -o orderer0.org1.example.com:7050 --channelID channel1 --name "simple-contract" --version 1.0 --sequence 1 --cafile $ORDERER_CA --peerAddresses ${IP_PEER_ORG1}:7051 --peerAddresses ${IP_PEER_ORG2}:8051 --signature-policy "OR('Org1MSP.peer','Org2MSP.peer')"
#peer lifecycle chaincode querycommitted --channelID channel1 --name "simple-contract" --cafile $ORDERER_CA

peer chaincode invoke -n "simple-contract" -c '{"Args":["Create", "KEY_1", "VALUE_1"]}' -C channel1
#peer chaincode invoke -n "simple-contract" -c '{"Args":["Create", "KEY_1", "VALUE_1"]}' -C channel1 -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA --peerAddresses ${IP_PEER_ORG1}:7051 --peerAddresses ${IP_PEER_ORG2}:8051

peer chaincode invoke -n simple-contract -c '{"Args":["Update", "KEY_1", "VALUE_2"]}' -C channel1
#peer chaincode invoke -n "simple-contract" -c '{"Args":["Update", "KEY_1", "VALUE_2"]}' -C channel1 -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA --peerAddresses ${IP_PEER_ORG1}:7051 --peerAddresses ${IP_PEER_ORG2}:8051
