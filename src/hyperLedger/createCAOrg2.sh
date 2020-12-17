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

export REGISTRAR_DIR=$PWD
export FABRIC_CA_CLIENT_HOME=$REGISTRAR_DIR

export ORG_DIR=$PWD/crypto-config/peerOrganizations/org2.example.com
export PEER_TLS=$PWD/peertls
export PEER_DIR=$ORG_DIR/peers/peer0.org2.example.com
export REGISTRAR_DIR=$ORG_DIR/users/admin
export ADMIN_DIR=$ORG_DIR/users/Admin@org2.example.com
export TLS=$ORG_DIR/tlsca
mkdir -p $ORG_DIR/ca $ORG_DIR/msp $PEER_DIR $REGISTRAR_DIR $ADMIN_DIR $TLS
mkdir certsICA

fabric-ca-client enroll -m admin -u http://adminCA:adminpw@localhost:7054 


fabric-ca-client register --id.name ca.org2.example.com --id.type client \
 --id.secret adminpw --csr.names C=ES,ST=Madrid,L=Madrid,O=org2.example.com \
 --csr.cn ca.org2.example.com -m ca.org2.example.com --id.attrs  '"hf.IntermediateCA=true"' -u http://localhost:7054 


docker-compose -f docker-compose-ca.yaml up -d ca.org2.example.com
sudo chmod 777 -R certsICA/
sudo chmod 777 -R certsICA/*
sudo chgrp  -R docker $PWD/certsICA/
sudo chown  -R 1000 $PWD/certsICA/
cp -r $PWD/certsICA/ $ORG_DIR/ca


