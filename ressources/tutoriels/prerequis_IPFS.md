# Prérequis
 
## Introduction

## Installation de IPFS

### Windows
```sh
# Télécharger le fichier binaire (attention, bien prendre la dernière version)
cd ~\ wget https://dist.ipfs.io/go-ipfs/v0.7.0/go-ipfs_v0.7.0_windows-amd64.zip -Outfile go-ipfs_v0.7.0.zip

# Décompresser l'archive
Expand-Archive -Path go-ipfs_v0.7.0.zip -DestinationPath ~\Apps\go-ipfs_v0.7.0

# Rentrer dans le dossier
cd ~\Apps\go-ipfs_v0.7.0\go-ipfs

# Copier le chemin du répertoire
pwd

# Ajouter ce chemin au PATH de PowerShell on l'ajoute à la fin du fichier ___profile.ps1___ stocké dans ___Documents\WindowsPowerShell___
Add-Content C:\Users\<utilisateur>\Documents\WindowsPowerShell\profile.ps1 "[System.Environment]::SetEnvironmentVariable('PATH',`$Env:PATH+';;C:\Users\<utilisateur>\Apps\go-ipfs_v0.7.0\go-ipfs')"
```

### MacOS
```sh
# Télécharger le fichier binaire (attention, bien prendre la dernière version)
wget https://dist.ipfs.io/go-ipfs/v0.7.0/go-ipfs_v0.7.0_darwin-amd64.tar.gz

# Décompresser l'archive
tar -xvzf go-ipfs_v0.7.0_darwin-amd64.tar.gz

# Rentrer dans le dossier
cd go-ipfs

# Exécuter install.sh
bash install.sh
```

### Linux
```sh
# Télécharger le fichier binaire (attention, bien prendre la dernière version)
wget https://dist.ipfs.io/go-ipfs/v0.7.0/go-ipfs_v0.7.0_linux-amd64.tar.gz

# Décompresser l'archive
tar -xvzf go-ipfs_v0.7.0_linux-amd64.tar.gz

# Rentrer dans le dossier
cd go-ipfs

# Exécuter install.sh
sudo bash install.sh
```

## Installation de Go
Go peut être utile à tout moment, il peut donc être utile de l'installer.

### Windows

### MacOS

### Linux
```sh
# mise à jour des dépendances
sudo apt-get update
sudo apt-get -y upgrade

# téléchargement de Go
wget https://dl.google.com/go/go1.15.4.linux-amd64.tar.gz
sudo tar -xvf go1.11.4.linux-amd64.tar.gz
sudo mv go /usr/local

# ajouter les variables d'environnement
mkdir $HOME/gopath

# ajouter les chemins à bashrc
sudo nano $HOME/.bashrc

export GOROOT=/usr/local/go
export GOPATH=$HOME/gopath
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# mettre à jour le fichier .bashrc
source ~/.bashrc

# pour finir on peut penser à supprimer les dossier compressés inutilisés
```

## Création d'un réseau privé

```sh
# télécharger la fonction pour le réseau privée (nécessite git)
go get -u github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen

# générer une clé et le mettre dans swarm.key
ipfs-swarm-key-gen > ~/.ipfs/swarm.key

# Copier ce fichier sur les autres noeuds du réseau

#supprimer toutes les adresses des bootstraps de chaque noeud
ipfs bootstrap rm --all

# On ajoute ensuite l'adresse du node0 sur TOUS les noeuds qui sera le responsable du cluster (<node id> s'obtient avec la commande ipfs id)
ipfs bootstrap add /ip4/<ip address>/tcp/4001/ipfs/<node id>

# On force IPFS a comprendre que c'est un réseau privée
export LIBP2P_FORCE_PNET=1

# Dans le fichier ~/.ipfs/config, modifier les addresses IP 127.0.0.1 de API et Gateway pour les adresses de chaque noeuds

# pour finir il n'y qu'à lancer le daemon
ipfs daemon &
```

# Faire tourner le daemon en tâche de fond
```sh
# Ajouter un fichier service
vi /etc/systemd/system/ipfs.service

# et coller les lignes suivantes avant d'enregistrer et quitter
[Unit]
Description=IPFS Daemon
After=syslog.target network.target remote-fs.target nss-lookup.target
[Service]
Type=simple
ExecStart=/usr/local/bin/ipfs daemon --enable-namesys-pubsub
User=root
[Install]
WantedBy=multi-user.target

# Install systemctl
apt install systemctl

# Appliquer ce service
systemctl daemon-reload
systemctl enable ipfs
systemctl start ipfs
systemctl status ipfs

# Si active failed, essayez de kill l'éventuel process en cours du service
ps aux
kill -9 <pid du service>
```

# Installer IPFS-Cluster
```sh
# Télécharger le repo de git
git clone https://github.com/ipfs/ipfs-cluster.git $GOPATH/src/github.com/ipfs/ipfs-cluster

# Entrer dans le dossier
cd $GOPATH/src/github.com/ipfs/ipfs-cluster

# Installer IPFS-Cluster (nécessite build-essential)
make install

# Si make ne fonctionne pas
apt install build-essential 

# Vérifier que l'installation a bien fonctionné
ipfs-cluster-service --version
ipfs-cluster-ctl --version
```

# Générer une clé secrète sur le noeud 0 nommé CLUSTER_SECRET
```sh
# Génération de la clé secrète uniquement sur le noeud 0
export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')

# Récupérer la clé
echo $CLUSTER_SECRET

# A exécuter sur toutes les machines. Pour conserver cette clé après fermeture du terminal copier la commande suivante dans ~/.bashrc
export CLUSTER_SECRET=<secret key>

# Pour relancer le fichier ~/.bashrc
source ~/.bashrc
```

# Intialiser et démarrer le cluster
```sh
# On démarre le cluster sur le noeud 0
#IMPORTANT : le daemon IPFS doit tourner avant de lancer le cluster
ipfs-cluster-service init

#Vérfier ensuite que l'adresse ip de node_multiaddress dans ipfshttp du fichier ~/.ipfs-cluster/service.json matche avec celui de la machine

# Trouver le peer id du node 0
cat ~/.ipfs-cluster/identity.json


ipfs-cluster-service daemon &

# Prendre le noeud suivant
ipfs-cluster-service init

#Vérfier ensuite que l'adresse ip de node_multiaddress dans ipfshttp du fichier ~/.ipfs-cluster/service.json matche avec celui de la machine

ipfs-cluster-service daemon --bootstrap /ip4/<ip address node0>/tcp/9096/ipfs/<peer id node0>
```

# Créer les services pour IPFS Cluster
```sh
# Ajouter un fichier service
vi /etc/systemd/system/ipfs-cluster.service

# et coller les lignes suivantes avant d'enregistrer et quitter (note execStart : le path pour ipfs-cluster-service s'obtient avec where ipfs-cluster-service)
[Unit]
Description=IPFS-Cluster Daemon
Requires=ipfs
After=syslog.target network.target remote-fs.target nss-lookup.target ipfs
[Service]
Type=simple
ExecStart=/root/gopath/bin/ipfs-cluster-service daemon
User=root
[Install]
WantedBy=multi-user.target


# Install systemctl
apt install systemctl

# Appliquer ce service
systemctl daemon-reload
systemctl enable ipfs-cluster
systemctl start ipfs-cluster
systemctl status ipfs-cluster

# Si active failed, essayez de kill l'éventuel process en cours du service
ps aux
kill -9 <pid du service>
```

# Notes
Prochaine étape
Gérer la transmission d'une image à Fred / Frantz et voir quels sont les conflits qu'on obtient. 


# Instructions pour instancier un réseau IPFS
```sh
# Charger le fichier compressé comme image docker
docker load <chemin vers le fichier compressé>

# Lancer un conteneur à partir de cette image (ce sera l'admin : node0)
docker container run -it  --name node0 startup-ipfs-node:v0.3 /bin/bash

# Dans le terminal du conteneur aller dans le bon répertoire
cd /home/ipfs_repo

# Initialiser IPFS pour l'admin
sh init-admin.sh

# Copier le contenu du fichier config tout juste généré (à faire à la main)

# Dans un nouveau terminal lancer un nouveau conteneur (ce sera un noeud normal : node1)
docker container run -it  --name node1 startup-ipfs-node:v0.3 /bin/bash

# Dans le terminal du conteneur aller dans le bon répertoire
cd /home/ipfs_repo

# Coller le contenu de config dans un fichier du même nom
vi config #puis coller le contenu

# Initialiser IPFS pour ce noeud
sh init-node.sh
```



# Sources
- [Tutoriel sur la mise en place d'un réseau IPFS privé](https://labs.eleks.com/2019/03/ipfs-network-data-replication.html)

