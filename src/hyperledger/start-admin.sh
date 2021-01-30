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

#read -p "Press any key to finish ..."echo "starting peer0.org2"
echo "starting peer0.org1"
docker-compose -f docker-compose.yaml up -d peer0.org1.example.com
export IP_PEER_ORG1=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.org1.example.com)
docker exec -it cli sh -c "export IP_PEER_ORG1="$IP_PEER_ORG1
echo "Org1 joining channel"
docker exec -it cli sh -c "./scripts/02-joinOrg1.sh"
echo "Installing CC adminConfig Org1"
docker exec -it cli sh -c "./scripts/03-installCCadminConfigOrg1.sh"
echo "Installing CC file Org1"
docker exec -it cli sh -c "./scripts/03-installCCfileOrg1.sh"
