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
CORE_PEER_LOCALMSPID="Org1MSP"
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com.crt.pem

CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=${IP_PEER_ORG1}:7051
CHANNEL_NAME=channel1
CORE_PEER_TLS_ENABLED=false
ORDERER_SYSCHAN_ID=syschain



#read -p "Press any key to continue (check commit readiness) ..."
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name "file-contract" --version 1.0 --cafile $ORDERER_CA --output json --sequence 1 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" #2>/dev/null
#read -p "Press any key to continue (commit chainecode) ..."
peer lifecycle chaincode commit -o orderer0.org1.example.com:7050 --channelID $CHANNEL_NAME --name "file-contract" --version 1.0 --sequence 1 --cafile $ORDERER_CA --peerAddresses ${IP_PEER_ORG1}:7051 --peerAddresses ${IP_PEER_ORG2}:8051 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" #2>/dev/null
