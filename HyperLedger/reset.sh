docker rm -f $(docker ps -aq)
docker volume prune
rm -r certsICA/

rm -r crypto-config

rm -r msp

rm -r channel-artifacts


