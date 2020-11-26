# Link Web server to IPFS
- ipfs-http-client
- ejs
- express pour mettre en place le serveur
- express file upload pour upload
fichiers sur IPFS
- body-parser pour parser des requêtes POST

La communication avec le noeud IPFS se fait par défaut une API disponible sur le port 5001 et le protocole HTTP (exemple dans la vidéo)

# IPFS Cluster
IPFS Cluster utilise 3 ports par défaut :
- 9096/tcp pour commmuniquer avec les autres noeuds
- 9094/tcp pour l'API HTTP
- 9095/tcp pour l'API Proxy

Cluster IPFS semble gérer l'autorepinned en cas de downtime. On peut également gérer ça manuellement et désactiver cette fonction

<blockquote cite="https://cluster.ipfs.io/documentation/deployment/setup/">
Consider increasing the cluster.monitor_ping_interval and monitor.*.check_interval. This dictactes how long cluster takes to realize a peer is not responding (and potentially trigger re-pins). Re-pinning might be a very expensive in your cluster. Thus, you may want to set this a bit high (several minutes). You can use same value for both.<br><br>
Under the same consideration, you might want to set cluster.disable_repinning to true if you don’t wish repinnings to be triggered at all on peer downtime and want to handle things manually when content becomes underpinned. replication_factor_max and replication_factor_min allow some leeway: i.e. a 2⁄3 will allow one peer to be down without re-allocating the content assigned to it somewhere else.
<footer>
<div style="text-align: right">
from <a href="https://cluster.ipfs.io/documentation/deployment/setup/">Cluster IPFS documentation (cluster section)</a>
</div>
</footer>
</blockquote>

# HyperLedger Fabric

C'est une plateforme ___permissioned___ ce qui signifie que les noeuds se connaissent et peuvent se faire confiance.
C'est également la première plateforme distribué de registres qui support les ___smart contracts___ avec des langages comme Java, Go et Node.js

Le ___pluggable consensus protocols___ permet plus de flexibilité pour s'adapter aux différents cas pratiques et aux modèles de confiance (trust models). C'est à dire qu'il existe différents protocoles de conscensus.

<blockquote cite="https://hyperledger-fabric.readthedocs.io/en/release-2.2/whatis.html">
For instance, when deployed within a single enterprise, or operated by a trusted authority, fully byzantine fault tolerant consensus might be considered unnecessary and an excessive drag on performance and throughput. In situations such as that, a crash fault-tolerant (CFT) consensus protocol might be more than adequate whereas, in a multi-party, decentralized use case, a more traditional byzantine fault tolerant (BFT) consensus protocol might be required.
<footer>
<div style="text-align: right">
from <a href="https://hyperledger-fabric.readthedocs.io/en/release-2.2/whatis.html">Hyperledger Fabric - Introduction</a>
</div>
</footer>
</blockquote>

## Modularity
Il possède une architecture modulaire permettant de définir différents types de conscensus mais également des protocoles de management d'identités (LDAP, OpenID Connect), de management de clés

## Permissioned vs Permissionless Blockchains

<blockquote cite="https://hyperledger-fabric.readthedocs.io/en/release-2.2/whatis.html">
A permissioned blockchain provides a way to secure the interactions among a group of entities that have a common goal but which may not fully trust each other. By relying on the identities of the participants, a permissioned blockchain can use more traditional crash fault tolerant (CFT) or byzantine fault tolerant (BFT) consensus protocols that do not require costly mining.
<footer>
<div style="text-align: right">
from <a href="https://hyperledger-fabric.readthedocs.io/en/release-2.2/whatis.html">Hyperledger Fabric - Permissioned</a>
</div>
</footer>
</blockquote>

En cas d'attaques, l'auteur peut être simplement identifié. Car toutes les actions sont enregistrés sur la blockchain en suivant une politique dites ___endorsement policy___ établie selon le réseau et le type de transaction.

## Smart Contracts
Fabric emploi le terme **chaincode** pour désigner les **Smart Contracts**
Il y a 3 points clés qui s'applique sur les smart contracts lorsqu'ils sont appliqués sur une plateforme :
- beaucoup de smart contracts tourne en concurrence sur le réseau
- ils peuvent être déployés dynamiquement (par n'importe qui souvent)
- les "application code" doivent être considérés comme non digne de confgiance / malicieux

Dans une architecture ___order-execute___ des smarts contracts, le protocole de conscensus :
- valide puis effectue des transactions avant de les propoger à tous les noeuds
- chaque noeuds exécute les transactions reçu de manière séquentielle.

Souvent les smarts contracts doivent être écrit dans un langage comme Solidity pour éviter les cas non-déterministes (où la solution n'est jamais trouvé).

## Autres technos en permissioned platforms
Tendermint, Chain, and Quorum.


# Source
- [Building IPFS app with Node.js](https://www.youtube.com/watch?v=RMlo9_wfKYU)
- [Introduction complète sur IPFS en détails](https://www.youtube.com/watch?v=GJ2980DWdyc)