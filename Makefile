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

ROOT = $(shell pwd)

all : clean
	@ cd $(ROOT)/src/hyperledger; $(ROOT)/src/hyperledger/start.sh 
	@ cd $(ROOT)/src/ipfs/admin; $(ROOT)/src/ipfs/admin/init.sh
	@ cd $(ROOT)/src/ipfs/client; $(ROOT)/src/ipfs/client/init.sh

restart :
	@ docker-compose stop
	@ docker-compose start

clean :
	@ chmod u+x $(ROOT)/src/executable.sh
	@ $(ROOT)/src/executable.sh
	@ sudo $(ROOT)/src/hyperledger/reset.sh 
	@ #docker-compose down -v 1>/dev/null 2>/dev/null
	@ sudo rm -rdf $(ROOT)/src/ipfs/*/data/
	@ docker container prune

mrproper : clean
	@ docker system prune 
	@ docker image rm ipfs/goipfs ipfs/ipfs-cluster ipfs-setup ipfs-cluster-setup