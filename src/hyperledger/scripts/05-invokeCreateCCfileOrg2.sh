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

# 1 argument is required, which is the json containing all the info about the file

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org1.example.com/orderers/orderer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com.crt.pem
CORE_PEER_LOCALMSPID="Org2MSP"
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com.crt.pem
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_ADDRESS=${IP_PEER_ORG2}:8051
CHANNEL_NAME=channel1
CORE_PEER_TLS_ENABLED=false
ORDERER_SYSCHAN_ID=syschain
ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/filechain/crypto-config/peerOrganizations/org2.example.com/ca/ca-cert.pem

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters.1 arguments required."
    exit 1
fi

json=$1


#read -p "Press any key to continue (invoke Create) ..."
peer chaincode invoke -o orderer0.org1.example.com:7050 --cafile $ORDERER_CA -C $CHANNEL_NAME -n file-contract --peerAddresses $CORE_PEER_ADDRESS --cafile $ORG2_CA -c '{"Args":["Create", "'${json}'"]}' #2>/dev/null
