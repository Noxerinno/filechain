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

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     docker="docker";;
    Darwin*)    docker="docker";;
    CYGWIN*)    docker="winpty docker";;
    MINGW*)     docker="winpty docker";;
    *)          docker="docker"
esac

CONTAINERS_ID=$(docker ps -aq)

$docker rm -f $CONTAINERS_ID
$docker volume prune

rm -r crypto-config

rm -r msp

rm -r channel-artifacts

rm channel1.block

rm text.txt

rm log.txt

rm adminConfig-contract.tar.gz

rm file-contract.tar.gz

read -p "Press any key to finish ..."

