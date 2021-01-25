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

# get the main hash for the file
PREFIX=$(docker exec $CONTAINER ipfs add --only-hash -Q /home/$FILENAME)
echo $PREFIX

# check if chunks folder already exists
docker exec $CONTAINER test -d /home/chunks
if [ $? -ne 0 ]
then
	docker exec $CONTAINER mkdir /home/chunks/
fi

# cleaning the folder and create the shards
docker exec $CONTAINER sh -c "cd /home/chunks;split -b $CHUNK_SIZE /home/$FILENAME $PREFIX"
echo "File splitted in chunks"

# get all hash from the shards
> ./shards.txt
docker exec $CONTAINER sh -c "ls /home/chunks > /home/shards.txt"
docker cp $CONTAINER:/home/shards.txt ./shards.txt
docker exec $CONTAINER rm /home/shards.txt

# add all shards to ipfs + craeting the list
> ./list.txt
CNT=0
WAITING="Adding files to IPFS"
while IFS= read -r line
do
	HASH=$(docker exec $CONTAINER sh -c "ipfs add -r -Q --pin=false /home/chunks/$line")
	echo "$HASH-$CNT" >> ./list.txt
	CNT=$(($CNT+1))
	echo -ne $WAITING'\r'
	WAITING+='.'
done < "shards.txt"
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
docker exec $CONTAINER sh -c "rm /home/$FILENAME;rm /home/chunks/*"