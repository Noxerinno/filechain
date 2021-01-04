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

docker-compose -f docker-compose-ca.yaml up -d ca.root.example.com
sleep 10
export IP_ROOT=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.root.example.com)
./createCAOrg1.sh
sleep 10
./createCertsOrg1.sh
sleep 10
sudo rm -r certsICA/
./createCAOrg2.sh
sleep 10
./createCertsOrg2.sh
sleep 10
./generate-artifacts.sh
sleep 10
echo "starting peer0.org1"
docker-compose up -d peer0.org1.example.com
export IP_PEER_ORG1=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.org1.example.com)
echo "starting peer0.org2"
docker-compose up -d peer0.org2.example.com
export IP_PEER_ORG2=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.org2.example.com)
echo "starting all containers"
docker-compose up -d

echo "exec in cli"
echo "Creation channel"
docker exec -it cli sh -c "./scripts/01-createchannel.sh"
sleep 10
echo "Org1 joining channel"
docker exec -it cli sh -c "./scripts/02-joinOrg1.sh"
#sleep 10
#echo "Org2 joining channel"
#docker exec -it cli sh -c "./scripts/02-joinOrg2.sh"
sleep 10
echo "Installing hyperledger go stuff"
docker exec -it cli sh -c "go get github.com/hyperledger/fabric-chaincode-go/shim"
sleep 10
docker exec -it cli sh -c "./scripts/test.sh"
sleep 10
#echo "Installing CC Org1"
#docker exec -it cli sh -c "./scripts/03-installCCorg1.sh"
#sleep 10
#echo "Instancing CC Org1"
#docker exec -it cli sh -c "./scripts/04-instanciateCCorg1.sh"
#sleep 10
#echo "Invoking CC Org1"
#docker exec -it cli sh -c "./scripts/05-invokeCCorg1.sh"
#sleep 10
#echo "Querying CC Org1"
#docker exec -it cli sh -c "./scripts/06-queryCCorg1.sh"









