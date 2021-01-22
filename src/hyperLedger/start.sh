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
#!/bin/bash

# This first step of the script allows to define on which OS we are, and take necessary actions
unameOut="$(uname -s)"
case "${unameOut}" in
	# If we are on Linux use the standard docker command
    Linux*)     docker="docker";;
	# If we are on Mac OS use the standard docker command
    Darwin*)    docker="docker";;
	# If we are on Windows is winpty in front of the docker command
    CYGWIN*)    docker="winpty docker";;
    MINGW*)     docker="winpty docker";;
	# In any other case, just use the docker command
    *)          docker="docker"
esac
docker-compose -f docker-compose-ca.yaml up -d ca.root.example.com
sleep 1
export IP_ROOT=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.root.example.com)
echo ${IP_ROOT}
sleep 10
docker-compose -f docker-compose-ca.yaml up -d ca-cli
sleep 10
#read -p "Press any key to continue (createCAOrg1) ..."
$docker exec -it ca-cli sh -c "./createCAOrg1.sh"
sleep 10
#read -p "Press any key to continue (up ca.org1.example.com) ..."
docker-compose -f docker-compose-ca.yaml up -d ca.org1.example.com
sleep 1
export IP_ORG1=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.org1.example.com)
echo ${IP_ORG1}
#read -p "Press any key to continue (createCertsOrg1) ..."
$docker exec -it ca-cli sh -c "./createCertsOrg1.sh ${IP_ORG1}"
sleep 10
#read -p "Press any key to continue (createCAOrg2) ..."
$docker exec -it ca-cli sh -c "./createCAOrg2.sh"
sleep 10
#read -p "Press any key to continue (up ca.org2.example.com) ..."
docker-compose -f docker-compose-ca.yaml up -d ca.org2.example.com
sleep 1
export IP_ORG2=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.org2.example.com)
echo ${IP_ORG2}
#read -p "Press any key to continue (createCertsOrg2) ..."
$docker exec -it ca-cli sh -c "./createCertsOrg2.sh ${IP_ORG2}"
sleep 10
#read -p "Press any key to continue (generate-artifacts) ..."
$docker exec -it ca-cli sh -c "./generate-artifacts.sh"
sleep 10
#read -p "Press any key to continue ..."
echo "starting peer0.org1"
docker-compose up -d peer0.org1.example.com
export IP_PEER_ORG1=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.org1.example.com)
echo "starting peer0.org2"
docker-compose up -d peer0.org2.example.com
export IP_PEER_ORG2=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.org2.example.com)
echo "starting all containers"
docker-compose up -d
sleep 10
echo "exec in cli"
echo "Creation channel"
$docker exec -it cli sh -c "./scripts/01-createchannel.sh"
echo "Org1 joining channel"
$docker exec -it cli sh -c "./scripts/02-joinOrg1.sh"
echo "Org2 joining channel"
$docker exec -it cli sh -c "./scripts/02-joinOrg2.sh"
echo "Installing CC Org1"
docker exec -it cli sh -c "./scripts/03-installCCorg1.sh"
echo "Installing CC Org2"
docker exec -it cli sh -c "./scripts/03-installCCorg2.sh"
echo "Commiting CC from Org1"
docker exec -it cli sh -c "./scripts/04-commitCCfromOrg1.sh"
echo "Creating CC from Org1"
docker exec -it cli sh -c './scripts/05-invokeCreateCCfromOrg1.sh "1" "2" "3" "4" "5"'
echo "Updating CC from Org1"
docker exec -it cli sh -c './scripts/06-invokeUpdateCCfromOrg1.sh "1" "1" "8" "3" "4" "5"'
echo "Querying CC from Org2"
docker exec -it cli sh -c "./scripts/07-queryReadAllCCorg2.sh"


read -p "Press any key to finish ..."
