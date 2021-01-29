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
CONTAINER="admin_ipfs"

SORTED=$(echo "$1" | jq '.shards|=sort_by(.position)')
# Check if correct number of arguments
if [ $# -ne 3 ]
then
    echo "Expect three arguments which is a string corresponding to the file json object, the filename and the destination folder"
    exit 
fi

# Check if retrieve folder "retrieve" exist in docker container
docker exec -it $CONTAINER test -d /home/retrieve
if [ $? -ne 0 ]
then
	docker exec -it $CONTAINER mkdir /home/retrieve/
fi

# get each shards from IPFS
PROCESSING="Downloading file"
QUERY=""
for shard in $(echo "${SORTED}" | jq -c '.shards[]'); do
    HASH=$(echo "$shard" | jq '.hash')
    QUERY+=" $HASH"
    docker exec $CONTAINER sh -c "cd /home/retrieve;ipfs get $HASH" &> /dev/null
    echo -ne $PROCESSING'\r'
    PROCESSING+='.'
done

docker exec -it $CONTAINER sh -c "cd /home/retrieve;cat$QUERY > ../$2"

# copy the file to local machine
docker cp $CONTAINER:/home/$2 $3

# cleaning files
docker exec -it $CONTAINER sh -c "rm /home/retrieve/*; rm /home/$2"