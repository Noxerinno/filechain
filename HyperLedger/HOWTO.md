# Dossiers générés par ce script
- certICA
- channel-artifacts
- crypto-config
- msp

# Liste des commandes détaillés
Avant de commencer, s'assurer qu'on a ajouter le dossier bin/ contenant les binaires utiles pour Hyperledger Fabric à son PATH
```
export PATH=$PATH:/path/to/bin
```

```
docker-compose -f docker-compose-ca.yaml up -d ca.root.example.com

# les commandes suivantes servent à modifier ca.root par l'ip
docker exec -it ca.root.example.com sh
getent hosts `hostname` | awk '{print $1}' # dans le conteneur
# copier l'adresse IP (noté $IP)
# sortir du conteneur
# modifier la commande au lancement de ica.dummyOrg (ca.root ==> $IP) dans le fichier docker-compose-ca.yml
# dans le fichier fabric-ca-client-config.yaml, modifier l'url ligne 43 avec $IP


./createCA.sh
./createCerts.sh
./generate-artifacts.sh
docker-compose up -d

# on récupère l'adresse IP de peer0
docker exec -it peer0.org1.example.com bash
getent hosts `hostname` | awk '{print $1}' # dans le conteneur
# copier l'adresse IP (noté $IP_PEER)
# sortir du conteneur
# dans le fichier scripts/01-createchannel.sh, modifier la variable $CORE_PEER_ADDRESS par $IP_PEER

# on entre ensuite dans le cli pour créer le channel
docker exec -it cli bash
./scripts/01-createchannel.sh
./scripts/02-joinOrg1.sh
```

# Pour tout arrêter
```
sudo ./reset.sh
``` 
