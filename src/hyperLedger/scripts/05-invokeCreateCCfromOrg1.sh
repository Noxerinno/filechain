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
ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/ca/ca-cert.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_ADDRESS=${IP_PEER_ORG1}:7051
CHANNEL_NAME=channel1
CORE_PEER_TLS_ENABLED=false
ORDERER_SYSCHAN_ID=syschain

#read -p "Press any key to continue (invoke Create) ..."
peer chaincode invoke -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA -C $CHANNEL_NAME -n simple-contract --peerAddresses $CORE_PEER_ADDRESS --cafile $ORG1_CA -c '{"Args":["Create", "12D3KooWSEb9pcJZCrYqfFeJVJ8uhn6KPXz4fgnNUbz8w5WUMrTv", "172.19.0.2","/key/swarm/psk/1.0.0/\\n/base16/\\n4e0ac296473bc1704d3530533ce731508614ef9e7e1bfaf007f293e05175828f","f2ab2bbdf43824c5ebaccd40fc7e3e3438a8c984dc44848c7aead931d9522d5a","12D3KooWRAgBLBMaxhMHn8WgDbGMN8LFvhsS8mia7uDf1q6aAMnN"]}'
