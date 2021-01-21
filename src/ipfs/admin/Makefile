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


all : clean
	@ # docker-compose up -d 
	@ # python3 init.py
	@ chmod u+x ./init.sh
	@ ./init.sh

restart :
	@ docker-compose stop
	@ docker-compose start

clean :
	@ docker-compose down
	@ # docker volume rm admin_ipfs_data
	@ # docker volume rm admin_ipfs-cluster_data
	@ # docker container stop $(docker ps -aq) 2>/dev/null
	@ sudo rm -rdf ./data/
	@ docker system prune
	@ # docker image rm ipfs-setup 1>/dev/null