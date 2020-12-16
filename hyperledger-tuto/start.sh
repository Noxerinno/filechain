docker-compose -f docker-compose-ca.yaml up -d ca.root
sleep 10
export IP_ROOT=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ca.root)
./createCA.sh
sleep 10
./createCerts.sh
sleep 10
./generate-artifacts.sh
sleep 10
echo "starting peer0"
docker-compose up -d peer0.dummyOrg.com
export IP_PEER=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' peer0.dummyOrg.com)

echo "starting all containers"
docker-compose up -d

echo "exec in cli"
docker exec -it cli sh -c "./scripts/01-createchannel.sh"
sleep 10
docker exec -it cli sh -c "./scripts/02-joinOrg1.sh"

