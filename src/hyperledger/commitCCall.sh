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

echo "Commiting CC adminConfig from Org1"
docker exec -it cli sh -c "./scripts/04-commitCCadminConfigOrg1.sh"
echo "Commiting CC file from Org1"
docker exec -it cli sh -c "./scripts/04-commitCCfileOrg1.sh"
