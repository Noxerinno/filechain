docker rm -f $(docker ps -aq)
docker volume prune
sudo rm -r certsICA/

sudo rm -r crypto-config

sudo rm -r msp

sudo rm -r channel-artifacts


