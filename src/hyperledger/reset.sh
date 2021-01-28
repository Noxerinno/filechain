#!/bin/bash

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

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     docker="docker";;
    Darwin*)    docker="docker";;
    CYGWIN*)    docker="winpty docker";;
    MINGW*)     docker="winpty docker";;
    *)          docker="docker"
esac

CONTAINERS_ID=$(docker ps -aq)

$docker rm -f $CONTAINERS_ID 1>/dev/null 2>/dev/null 
#$docker volume prune

[ -d "crypto-config" ] && rm -rd crypto-config

[ -d "msp" ] && rm -rd msp

[ -d "channel-artifacts" ] && rm -rd channel-artifacts

[ -f "channel1.block" ] && rm channel1.block

[ -f "text.txt" ] && rm text.txt

[ -f "log.txt" ] && rm log.txt

[ -f "adminConfig-contract.tar.gz" ] && rm adminConfig-contract.tar.gz

[ -f "file-contract.tar.gz" ] && rm file-contract.tar.gz

read -p "Press any key to finish ..."