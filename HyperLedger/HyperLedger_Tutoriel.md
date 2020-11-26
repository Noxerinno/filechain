# HyperLedger Tutoriel

## Pré-requis
  - Git
  - Curl ( :warning: Sur windows l'installation de curl est plus complexe :warning: )
  - Docker et Docker Compose
  - Go

## Installation de HyperLedger

### Installation des Samples, Binaries, and Docker Images
 Afin d'installer hyperledger, tapez la commande suivante:
 ```curl -sSL https://bit.ly/2ysbOFE | bash -s```  
> Il est possible que la commande suivante ne fonctionne pas sur Windows. Si c'est le cas exécuter directement le fichier scriptHyperLedger.sh situé dans le dossier script. Sinon téléchargez le projet sur le lien suivant https://github.com/hyperledger/fabric-samples.     
> :warning: Si docker n'a pas été installer la commande précédente et le script ne téléchargeront pas les images dockers. Donc veuillez vérifier que Docker a bien été préalablement installé et qu'il fonctionne. :warning:  
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

### Lancement du réseau
Avant d'exécuter des commandes, s'assurer que l'anti-virus est désactivé.  
 ```cd fabric-samples/test-network```

 On lance la commande suivante afin de s'assurer qu'il n'y a pas d'anciens conteneurs ou artefacts :  
 ```./network.sh down```  
 Puis on lance le réseau :  
 ```./network.sh up```


### Création d'un channel
 A la suite de cette commande, 3 noeuds sont créés ils peuvent être vus avec la commande ```docker ps -a```. Dont 2 pairs ([peer]) chacun gérés par une organisation et un *[orderer]* qui s'occupe de gérer le réseau.  
 Pour créer un [channel] entre Org1 et Org2, lancez ```./network.sh createChannel```  
 puis ```./network.sh createChannel -c channel2``` pour lancer un deuxième channel avec un nom personnalisé. Par défaut ça sera mychannel.  
 > La commande ```./network.sh up createChannel``` permet de lancer le réseau et de créer un channel.  

### Déploiement d'un smart contract
 On lance la commande ```./network.sh deployCC``` qui permet de déployer un [chaincode] (smart contract) sur le réseau.  
 > Si aucun nom de channel n'est spécifié, le chaincode sera déployé sur mychannel. Pour spécifier un channel il faut utiliser ```./network.sh deployCC -c <nom-du-channel>```  

### Intéragir avec le réseau
 Si ça n'a toujours pas été fait ajouter le dossier *bin* situé dans le dossier *fabric-samples* dans le PATH afin de pouvoir utiliser le fichier binaire peer par la suite. Il faut mettre en place la variable FABRIC_CFG_PATH pour pointer vers le fichier *core.yaml* situé dans le dossier *config* de *fabric-samples*.  

Pour ensuite intéragir avec peer en tant que ORg1, il faut mettre en place les variables d'environnement suivantes:
> Environment variables for Org1  
>export CORE_PEER_TLS_ENABLED=true  
>export CORE_PEER_LOCALMSPID="Org1MSP"  (Sur Windows pas besoin de mettre ")  
>export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt  
>export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp  
>export CORE_PEER_ADDRESS=localhost:7051  

Une fois les variables d'environnement mises en place, on peut initializer le ledger avec les assets défini dans le fichier chaincode.go  
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
```
Si ça fonctionne il devrait y avoir le message suivant: `-> INFO 001 Chaincode invoke successful. result: status:200` 
Sinon c'est qu'il y a eu un problème à l'etape précedente.  

La commande pour afficher les assets qu'on vient de mettre sur le ledger  
`peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}`  

Les chaincodes sont appelés lorsqu'on veut transférer ou changer des assets  
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'
```
> On change le propriétaire de l'asset6 qui était Michel par Christopher.
Si ça fonctionne le message suivant apparait: `2019-12-04 17:38:21.048 EST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200`  
Tu peux également afficher les assets et voir que "asset6" a changé.  

On va maintenant se mettre à la place de Org2 en changeant les variables d'environnement comme précedemment:
>Environment variables for Org2  
>export CORE_PEER_TLS_ENABLED=true  
>export CORE_PEER_LOCALMSPID="Org2MSP"  (Sur Windows pas besoin de mettre ")  
>export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt  
>export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp  
>export CORE_PEER_ADDRESS=localhost:9051  

Une fois après mis en tant que Org2, en lançant `peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'`, on peut voir que propriétaire de asset6 est bien Christopher et donc que la transaction a bien été changée chez toutes les organisations.  

En exécutant la commande `./network.sh down`, on éteint le réseau et on supprime tous ce qu'on a pu faire dessus.

## Première application

On repart d'un projet vierge. Exécutez à nouveau le fichier *script.sh* et allez dans le dossier *fabric-samples/test-network* pour exécuter la commande:  
`./network.sh up createChannel -c mychannel -ca`  
`./network.sh deployCC -ccn basic -ccl go` On déploie le chaincode en langage go  
> Vous pouvez lancer `docker logs -f ca_org1` dans un autre terminal afin d'aggicher les logs du Certificate Authorities. Si la commande ne marche pas c'est qu'il y a eu une erreur à une étape précédente.  

La commande `go run assetTransfer.go` situé dans *fabric-samples/asset-transfer-basic/application-go* permet de générer les identifiants de l'administrateur à partir du certificat créé précedemment et qui seront stockés dans le *wallet* du même dossier.  
>Il se peut que programme ne se lance pas à cause de chemin d'accès introuvable. Si c'est le cas alors que le chemin d'accès existe voici plusieurs solutions:  
> - Recommencer un travail vierge si cela n'avait pas encore été fait en éteignant le réseau et en supprimant tous les dossiers pour ensuite les retélécharger en suivant les étapes précédentes.  
> - Si le fichier indiqué dans l'erreur du programme existe et qu'il a un nom très long alors renommez le fichier en un nom plus court(ex:key_sk) (Ce problème n'est survenu que sur Windows, à confirmer pour les autres OS).  
> - Si le fichier n'existe pas mais que vous avez un fichier du même type au même endroit mais d'un nom différent, renommez-le. Normalement vous devriez le renommer cert.pem (:warning: Cette solution est peu conseillée. Ne l'utiliser uniquement que si les autres solutions n'ont pas fonctionné. :warning:)  

Une fois que c'est fini tu peux fermer le réseau avec `./network.sh down

## Setup du réseau

Les fichiers *configtx.yaml* et *crypto-config.yaml* permettent de configurer les ressources du réseau (telles que les organisation les peers et orderers...) afin de générer leur certificat et fichiers associés en utilisant le script *script_crypto.sh*  

Pour lancer le réśeau on utilise le fichier *script.sh* (ou *script_alternate.sh*) mais pour le moment ne passe pas l'étape de création d'un channel


[Channel]:https://hyperledger-fabric.readthedocs.io/en/latest/glossary.html#channel
[Chaincode]:https://hyperledger-fabric.readthedocs.io/en/latest/glossary.html#chaincode
[Peer]:https://hyperledger-fabric.readthedocs.io/en/release-2.2/peers/peers.html
[Orderer]: https://hyperledger-fabric.readthedocs.io/en/release-2.2/orderer/ordering_service.html



