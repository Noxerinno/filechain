#!/bin/sh

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

/jq/jq -n '{"IpfsId": "","AdminIpAddress": "","SwarmKey":"","ClusterSecret": "","ClusterPeerId": ""}' > /jq/config-files/config
/jq/jq --arg IPADDR "$IPADDR" '.AdminIpAddress=$IPADDR' /jq/config-files/config > tmp && mv tmp /jq/config-files/config
/jq/jq --arg SWARM "$SWARMKEY" '.SwarmKey=$SWARM' /jq/config-files/config > tmp && mv tmp /jq/config-files/config
/jq/jq --arg NODEID "$NODEID" '.IpfsId=$NODEID' /jq/config-files/config > tmp && mv tmp /jq/config-files/config
/jq/jq --arg CLUSTER_SECRET "$CLUSTER_SECRET" '.ClusterSecret=$CLUSTER_SECRET' /jq/config-files/config > tmp && mv tmp /jq/config-files/config
/jq/jq --arg PEERID "$PEERID" '.ClusterPeerId=$PEERID' /jq/config-files/config > tmp && mv tmp /jq/config-files/config