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

pwd
docker-compose -f docker-compose-ca.yaml up -d ca.root.example.com
sleep 1
export IP_ROOT=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.root.example.com)
echo ${IP_ROOT}
sleep 5
docker-compose -f docker-compose-ca.yaml up -d ca-cli
sleep 5
#read -p "Press any key to continue (createCAOrg1) ..."
$docker exec -it ca-cli sh -c "./createCAOrg1.sh"
sleep 5
#read -p "Press any key to continue (up ca.org1.example.com) ..."
docker-compose -f docker-compose-ca.yaml up -d ca.org1.example.com
sleep 1
export IP_ORG1=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.org1.example.com)
echo ${IP_ORG1}
#read -p "Press any key to continue (createCertsOrg1) ..."
$docker exec -it ca-cli sh -c "./createCertsOrg1.sh ${IP_ORG1}"
sleep 5
#read -p "Press any key to continue (createCAOrg2) ..."
$docker exec -it ca-cli sh -c "./createCAOrg2.sh"
sleep 5
#read -p "Press any key to continue (up ca.org2.example.com) ..."
docker-compose -f docker-compose-ca.yaml up -d ca.org2.example.com
sleep 1
export IP_ORG2=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.org2.example.com)
echo ${IP_ORG2}
#read -p "Press any key to continue (createCertsOrg2) ..."
$docker exec -it ca-cli sh -c "./createCertsOrg2.sh ${IP_ORG2}"
sleep 5
#read -p "Press any key to continue (generate-artifacts) ..."
$docker exec -it ca-cli sh -c "./generate-artifacts.sh"
sleep 5

#read -p "Press any key to continue ..."
echo "starting all containers cli orderer0 and chaincode"
docker-compose -f docker-compose.yaml up -d orderer0.org1.example.com cli chaincode
sleep 5
echo "exec in cli"
echo "Creation channel"
$docker exec -it cli sh -c "./scripts/01-createchannel.sh"
read -p "Press any key to continue ..."
#Starting Admin(Org1)
./start-admin.sh
#Starting CLient(Org2)
./start-client.sh
#Commiting CC
./commitCCall.sh

#echo "Creating CC adminConfig from Org1"
#json1="{\\\\\\\"IpfsId\\\\\\\":\\\\\\\"1\\\\\\\",\\\\\\\"AdminIpAddress\\\\\\\":\\\\\\\"2\\\\\\\",\\\\\\\"SwarmKey\\\\\\\":\\\\\\\"3\\\\\\\",\\\\\\\"ClusterSecret\\\\\\\":\\\\\\\"4\\\\\\\",\\\\\\\"ClusterPeerId\\\\\\\":\\\\\\\"5\\\\\\\"}"
#json2="{\\\\\\\"IpfsId\\\\\\\":\\\\\\\"1\\\\\\\",\\\\\\\"AdminIpAddress\\\\\\\":\\\\\\\"28\\\\\\\",\\\\\\\"SwarmKey\\\\\\\":\\\\\\\"3\\\\\\\",\\\\\\\"ClusterSecret\\\\\\\":\\\\\\\"4\\\\\\\",\\\\\\\"ClusterPeerId\\\\\\\":\\\\\\\"5\\\\\\\"}"
#docker exec -it cli sh -c './scripts/05-invokeCreateCCadminConfigOrg1.sh '${json1}
#sleep 5
#echo "Updating CC adminConfig from Org1"
#docker exec -it cli sh -c './scripts/06-invokeUpdateCCadminConfigOrg1.sh "1" '${json2}
#echo "Querying CC adminConfig from Org2"
#sleep 5
#docker exec -it cli sh -c "./scripts/07-queryReadAllCCadminConfigOrg2.sh"


#echo "Creating CC file from Org1"
#json3="{\\\\\\\"main_hash\\\\\\\":\\\\\\\"QmUdQxj9mKZq2zgpKPEtHvx1gaV4vG2wBNLz3xuvoEM6r3\\\\\\\",\\\\\\\"filename\\\\\\\":\\\\\\\"monimage.jpg\\\\\\\",\\\\\\\"timestamp\\\\\\\":123456978656498463,\\\\\\\"mime-type\\\\\\\":\\\\\\\"image/jpeg\\\\\\\",\\\\\\\"shards\\\\\\\":[{\\\\\\\"hash\\\\\\\":\\\\\\\"QmXrPn23q8yyQxTrhEwTy9pbBafE2V7VsEn49DywWDPy4e\\\\\\\",\\\\\\\"position\\\\\\\":0},{\\\\\\\"hash\\\\\\\":\\\\\\\"QmaWTDDNwDHXh5zhgq8rHVhqYX9mZzbyuPRKqosFkxwYWn\\\\\\\",\\\\\\\"position\\\\\\\":2},{\\\\\\\"hash\\\\\\\":\\\\\\\"QmcPJDCz2tdcRMehXRZMxyGABw7RChmMCHJxgdrAKdbGTm\\\\\\\",\\\\\\\"position\\\\\\\":1}]}"
#json4="{\\\\\\\"main_hash\\\\\\\":\\\\\\\"QmUdQxj9mKZq2zgpKPEtHvx1gaV4vG2wBNLz3xuvoEM6r3\\\\\\\",\\\\\\\"filename\\\\\\\":\\\\\\\"monim age2.jpg\\\\\\\",\\\\\\\"timestamp\\\\\\\":123456978656498463,\\\\\\\"mime-type\\\\\\\":\\\\\\\"image/jpeg\\\\\\\",\\\\\\\"shards\\\\\\\":[{\\\\\\\"hash\\\\\\\":\\\\\\\"QmXrPn23q8yyQxTrhEwTy9pbBafE2V7VsEn49DywWDPy4e\\\\\\\",\\\\\\\"position\\\\\\\":0},{\\\\\\\"hash\\\\\\\":\\\\\\\"QmaWTDDNwDHXh5zhgq8rHVhqYX9mZzbyuPRKqosFkxwYWn\\\\\\\",\\\\\\\"position\\\\\\\":2},{\\\\\\\"hash\\\\\\\":\\\\\\\"QmcPJDCz2tdcRMehXRZMxyGABw7RChmMCHJxgdrAKdbGTm\\\\\\\",\\\\\\\"position\\\\\\\":1}]}"
#docker exec -it cli sh -c './scripts/05-invokeCreateCCfileOrg1.sh '${json3}
#sleep 5
#echo "Updating CC file from Org1"
#docker exec -it cli sh -c './scripts/06-invokeUpdateCCfileOrg1.sh "QmUdQxj9mKZq2zgpKPEtHvx1gaV4vG2wBNLz3xuvoEM6r3" '${json4}
#echo "Querying CC file from Org2"
#sleep 5
#docker exec -it cli sh -c "./scripts/07-queryReadAllCCfileOrg2.sh"
echo "Done"
# read -p "Press any key to finish ..."
