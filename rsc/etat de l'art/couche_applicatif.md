# Pinning Tool

Lorsqu'on réalise la commande "ipfs add", l'objet est par défaut pinné récursivement.

Dans le monde IPFS, il existe 3 types de pins:
- Direct pins : pin uniquement le bloc en question, sans prendre en compte les blocs potentiellement liés à celui-ci
- Recursive pins : pin un bloc ainsi que les enfants de ce dernier
- Indirect pins : c'est l'implication lorsqu'un qu'un bloc parent est pin récursivement 

## IPFS Cluster

Consensus en CRDT mode plus adapté pour le projet. Le cluster a plus de liberté pour varier.

Avantages:
- offre une solution pour ping les machines et savoir s'il est up ou non.
- indique la place restante dans son répertoire.


# Sources
- [Documentation IPFS : Pin files using IPFS](https://docs.ipfs.io/how-to/pin-files/)
- [Consensus en Cluster IPFS](https://cluster.ipfs.io/documentation/guides/consensus/)
- [Metriques de monitoring pour Cluster IPFS](https://cluster.ipfs.io/documentation/guides/metrics/)
- [Cluster IPFS article](https://medium.com/@rossbulat/using-ipfs-cluster-service-for-global-ipfs-data-persistence-69a260a0711c)