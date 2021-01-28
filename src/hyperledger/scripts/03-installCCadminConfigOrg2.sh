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

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/orderers/orderer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com.crt.pem
CORE_PEER_LOCALMSPID="Org2MSP"
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com.crt.pem
CHAINCODE_SOURCES_PATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/chaincodes/adminConfig

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=peer0.org2.example.com:8051
CHANNEL_NAME=channel1
CORE_PEER_TLS_ENABLED=false
ORDERER_SYSCHAN_ID=syschain


#STEP 1 PACKAGE THE SOURCE CODE
#read -p "Press any key to continue (package chaincode org2) ..."
peer lifecycle chaincode package adminConfig-contract.tar.gz --path $CHAINCODE_SOURCES_PATH --lang golang --label adminConfig-contract_1.0 2>/dev/null
#STEP 2 INSTALL THE PACKAGE IN PEER ORG1
#read -p "Press any key to continue (install chaincode org2) ..."
peer lifecycle chaincode install adminConfig-contract.tar.gz --peerAddresses $CORE_PEER_ADDRESS 2>/dev/null
#read -p "Press any key to continue (queryinstalled chaincode org2) ..."
#STEP 3 CHECK IF INSTALLED
touch text.txt
peer lifecycle chaincode queryinstalled > text.txt
export PACKAGE_ID=$(cat text.txt | grep  "Package ID" | cut -d' ' -f3 | sed 's/.$//' | grep "adminConfig-contract")
#read -p "Press any key to continue (approveformyorg approve $PACKAGE_ID org2) ..."
#STEP 3 APPROVE CHAINCODE ON ORG1
peer lifecycle chaincode approveformyorg -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name "adminConfig-contract" --version 1.0 --package-id $PACKAGE_ID --sequence 1 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" 2>/dev/null
