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

docker start cli peer0.org1.example.com peer0.org2.example.com orderer0.org1.example.com  orderer0.org2.example.com chaincode
sleep 5
export IP_PEER_ORG1=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.org1.example.com)
export IP_PEER_ORG2=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.org2.example.com)
docker exec -it cli sh -c "export IP_PEER_ORG1="${IP_PEER_ORG1}
docker exec -it cli sh -c "export IP_PEER_ORG2="${IP_PEER_ORG2}
json1="{\\\\\\\"IpfsId\\\\\\\":\\\\\\\"1\\\\\\\",\\\\\\\"AdminIpAddress\\\\\\\":\\\\\\\"2\\\\\\\",\\\\\\\"SwarmKey\\\\\\\":\\\\\\\"3\\\\\\\",\\\\\\\"ClusterSecret\\\\\\\":\\\\\\\"4\\\\\\\",\\\\\\\"ClusterPeerId\\\\\\\":\\\\\\\"5\\\\\\\"}"
json2="{\\\\\\\"IpfsId\\\\\\\":\\\\\\\"1\\\\\\\",\\\\\\\"AdminIpAddress\\\\\\\":\\\\\\\"28\\\\\\\",\\\\\\\"SwarmKey\\\\\\\":\\\\\\\"3\\\\\\\",\\\\\\\"ClusterSecret\\\\\\\":\\\\\\\"4\\\\\\\",\\\\\\\"ClusterPeerId\\\\\\\":\\\\\\\"5\\\\\\\"}"
docker exec -it cli sh -c './scripts/05-invokeCreateCCadminConfigOrg1.sh '${json1}
docker exec -it cli sh -c "./scripts/07-queryReadAllCCadminConfigOrg2.sh"