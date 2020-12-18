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

# Setting environment Variables #
export ORG_DIR=$PWD/crypto-config/peerOrganizations/org2.example.com
export PEER_DIR=$ORG_DIR/peers/peer0.org2.example.com
export ORDERER_DIR=$ORG_DIR/orderers/orderer0.org2.example.com
export REGISTRAR_DIR=$ORG_DIR/users/admin
export ADMIN_DIR=$ORG_DIR/users/Admin@org2.example.com
echo "[Step 1] Enroling client and registering peer and user identitities"

export FABRIC_CA_CLIENT_HOME=$REGISTRAR_DIR

# Enroll client to interact
fabric-ca-client enroll --csr.names C=ES,ST=Madrid,L=Madrid,O=org2.example.com -m admin -u http://admin:adminpw@localhost:9054 

sleep 10

# Register admin identity and peer
fabric-ca-client register --id.name Admin@org2.example.com --id.secret mysecret --id.type client --id.affiliation org2 -u http://localhost:9054 

fabric-ca-client register --id.name peer0.org2.example.com --id.secret mysecret --id.type peer --id.affiliation org2 -u http://localhost:9054 

fabric-ca-client register --id.name orderer0.org2.example.com --id.secret mysecret --id.type orderer --id.affiliation org2 -u http://localhost:9054 

sleep 3
echo "[Step 1] Completed"

echo "[Step 2] Creating admin certs"


export FABRIC_CA_CLIENT_HOME=$ADMIN_DIR
# Get certificates from ICA

fabric-ca-client enroll --csr.names C=ES,ST=Madrid,L=Madrid,O=org2.example.com -m Admin@org2.example.com -u http://Admin@org2.example.com:mysecret@localhost:9054 
mkdir -p $ADMIN_DIR/msp/admincerts && cp $ADMIN_DIR/msp/signcerts/*.pem $ADMIN_DIR/msp/admincerts/


echo "[Step 2] Completed"
echo "[Step 3] Creating peer certs"

export FABRIC_CA_CLIENT_HOME=$PEER_DIR
fabric-ca-client enroll --csr.names C=ES,ST=Madrid,L=Madrid,O=org2.example.com -m peer0.org2.example.com -u http://Admin@org2.example.com:mysecret@localhost:9054 
mkdir -p $PEER_DIR/msp/admincerts && cp $ADMIN_DIR/msp/signcerts/*.pem $PEER_DIR/msp/admincerts/
sleep 2
echo "[Step 3] Completed"
echo "[Step 4] Creating orderer certs"

export FABRIC_CA_CLIENT_HOME=$ORDERER_DIR
fabric-ca-client enroll --csr.names C=ES,ST=Madrid,L=Madrid,O=org2.example.com -m orderer.org2.example.com -u http://Admin@org2.example.com:mysecret@localhost:9054 
mkdir -p $ORDERER_DIR/msp/admincerts && cp $ADMIN_DIR/msp/signcerts/*.pem $ORDERER_DIR/msp/admincerts/
sleep 2
echo "[Step 4] Completed"
echo "[Step 5] Creating MSP for Organization 2"
# Generating scaffolding

mkdir -p $ORG_DIR/msp/admincerts $ORG_DIR/msp/intermediatecerts $ORG_DIR/msp/cacerts
cp $ADMIN_DIR/msp/signcerts/*.pem $ORG_DIR/msp/admincerts/
cp $PEER_DIR/msp/cacerts/*.pem $ORG_DIR/msp/cacerts/
cp $PEER_DIR/msp/intermediatecerts/*.pem $ORG_DIR/msp/intermediatecerts/
sleep 3
echo "[Step 5] Completed"
echo "[Step 6] Creating Scaffolfding"

cp -r $PWD/certsICA/* $ORG_DIR/ca
echo "[Step 6] Completed"

