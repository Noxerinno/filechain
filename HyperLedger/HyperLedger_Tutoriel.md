# HyperLedger Tutoriel

## Pré-requis
  - Git
  - Curl ( /!\Sur windows l'installation de curl est plus complexe /!\ )
  - Docker et Docker Compose

## Installation de HyperLedger

### Installation des Samples, Binaries, and Docker Images
 Afin d'installer hyperledger, tapez la commade suivante:
 ```curl -sSL https://bit.ly/2ysbOFE | bash -s```
> Il est possible que la commande suivante ne fonctionne pas sur Windows. Si c'est le cas exécuter directement le fichier scriptHyperLedger.sh situé dans le dossier script.
> /!\ Si docker n'a pas été installer la commande précédente et le script ne téléchargeront pas les images dockers. Donc veuillez vérifier que Docker a bien été préalablement installé et qu'il fonctionne.
> Il se peut que les dossier bin et config n'ait pas été installé alors que le script indique que si. Dans ce cas éventuel, les archives peuvent être télécharger via les liens suivants
>
> Pour Windows :
> - https://github.com/hyperledger/fabric/releases/download/v2.2.1/hyperledger-fabric-windows-amd64-2.2.1.tar.gz
> - https://github.com/hyperledger/fabric-ca/releases/download/v1.4.9/hyperledger-fabric-ca-windows-amd64-1.4.9.tar.gz
>
> Pour Linux :
> - https://github.com/hyperledger/fabric/releases/download/v2.2.1/hyperledger-fabric-linux-amd64-2.2.1.tar.gz
> - https://github.com/hyperledger/fabric/releases/download/v1.4.9/hyperledger-fabric-ca-linux-amd64-1.4.9.tar.gz

Les commandes situés dans le bin peuvent être ajouté au PATH pour faciliter les choses.
```export PATH=<path to download location>/bin:$PATH```

## Tester le réseau HyperLedger de l'exemple
Avant d'exécuter les fichiers s'assurer que l'anti-virus est désactivé.
 ```cd fabric-samples/test-network```
 On lance la commande suivante afin de s'assurer qu'il n'y a pas d'anciens conteneurs ou artefacts :
 ```./network.sh down```
 Puis on lance le réseau :
 ```./network.sh up```

 A la suite de cette commande, 3 noeuds sont créés ils peuvent être vus avec la commande ```docker ps -a```. Dont 2 pairs ([peer]) chacun gérés par une organisation et un *[orderer]* qui s'occupe de gérer le réseau.
 Pour créer un channel entre Org1 et Org2, lancez ```./network.sh createChannel```
 puis ```./network.sh createChannel -c channel2``` pour lancer un deuxième channel avec un nom personnalisé. Par défaut ça sera mychannel.
 > La commande ```./network.sh up createChannel``` permet de lancer le réseau et de créer un channel.
 
 [Peer]:https://hyperledger-fabric.readthedocs.io/en/release-2.2/peers/peers.html
 [Orderer]: https://hyperledger-fabric.readthedocs.io/en/release-2.2/orderer/ordering_service.html



