#!/bin/bash
ALPINE_VER=3.12
GO_VER=1.14.12

docker build -t setup-hyperledger-tools . --build-arg ALPINE_VER=$ALPINE_VER --build-arg GO_VER=$GO_VER
read -p "Press any key to finish ..."
