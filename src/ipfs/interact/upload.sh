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

CHUNK_SIZE="100k"
CONTAINER="admin_ipfs"
CONTAINER_CLUSTER="admin_cluster"
CONTAINER_JQ="jq-image"

# timestamp() {
#   date +"%T" # current time
# }

# get_mime_type(val) {
# 	file --mime-type val 
# }

# Check if correct number of argument
if [ $# -ne 1 ]
then
    echo "Only expect one argument which is the path to the file"
    exit 
fi

# Check if file exist
if [ ! -f $1 ]
then
    echo "$1 isn't a valid path on your filesystem."
    exit
fi

# Adding the targeted file to the container
docker cp $1 $CONTAINER:/home/
FILENAME=$(basename $1)
echo "$FILENAME"

# Getting file type
TYPE=$(file --mime-type $1 | cut -d ":" -f2 | cut -c 2-)

# get the main hash for the file
PREFIX=$(docker exec -it $CONTAINER ipfs add --only-hash -Q /home/$FILENAME)
echo $PREFIX

# check if chunks folder already exists
docker exec -it $CONTAINER test -d /home/chunks
if [ $? -ne 0 ]
then
	docker exec -it $CONTAINER mkdir /home/chunks/
fi

# cleaning the folder and create the shards
docker exec -it $CONTAINER sh -c "cd /home/chunks;split -b $CHUNK_SIZE /home/$FILENAME $PREFIX"
echo "File splitted in chunks"

# get all hash from the shards
> ./shards.txt
docker exec -it $CONTAINER sh -c "ls /home/chunks > /home/shards.txt"
docker cp $CONTAINER:/home/shards.txt ./shards.txt
docker exec -it $CONTAINER rm /home/shards.txt

#Creating the JSon file
jq --arg PREFIX "$PREFIX" --arg FILENAME "$FILENAME" --arg TIMESTAMP "$TIMESTAMP" --arg TYPE "$TYPE" -n '{
	"main_hash": $PREFIX,
	"filename": $FILENAME,
	"timestamp": $TIMESTAMP,
	"mime-type": $TYPE,
	"shards": []
}' > ./shards.json

# add all shards to ipfs + creating the list
> ./list.txt
CNT=0
WAITING="Adding files to IPFS"
while IFS= read -r line
do
	HASH=$(docker exec $CONTAINER sh -c "ipfs add -r -Q --pin=false /home/chunks/$line")
	echo "$HASH-$CNT" >> ./list.txt
	CNT=$(($CNT+1))

	# Adding shards' info to shard list
	jq --arg HASH "$HASH" --arg CNT "$CNT" -n '.data.shards += [{
		"hash": $HASH,
		"position": $CNT
	}]' > ./shards.json

	echo -ne $WAITING'\r'
	WAITING+='.'
done # < "shards.txt"
echo -ne "\n"
echo "Uploaded"

# pin all shards using IPFS Cluster
WAITING2="Pinning files"
while IFS=" - " read -r line
do
	HASH=$(echo $line | cut -d'-' -f1)
	docker exec $CONTAINER_CLUSTER sh -c "ipfs-cluster-ctl pin add --no-status --replication 1 $HASH > /dev/null" # ne pas attendre son retour 
	echo -ne $WAITING2'\r'
	WAITING2+='.'
done < "list.txt"
echo -ne '\n'
echo "Synced"
# Cleaning unsed files
docker exec -it $CONTAINER sh -c "rm /home/$FILENAME;rm /home/chunks/*"
