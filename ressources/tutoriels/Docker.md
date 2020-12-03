# Docker

Ce document regroupes l'ensemble de mes notes prises durant mes recherches sur Docker

## Sommaire

- [Docker](#docker)
  - [Sommaire](#sommaire)
  - [Basics](#basics)
  - [Docker Compose](#docker-compose)
    - [Structure type d'un *docker-compose.yml*](#structure-type-dun-docker-composeyml)
    - [Commandes utiles](#commandes-utiles)
  - [Docker Swarm](#docker-swarm)
  - [Kubernetes](#kubernetes)
  - [To do](#to-do)

## Basics

Voir le rapport de Johan

## Docker Compose

Docker Compose permet la création et l'orchestration de stack Docker. Une stack et un ensemble logique de conteneurs Docker. Les conteneurs composant la stack sont appelés des services.

### Structure type d'un *docker-compose.yml*

```Docker
version: '3'
services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: somewordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    ports:
      - "8000:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress

volumes:
  db_data: {}
```

### Commandes utiles

- `docker-compose up` : Permet de **démarrer** une stack (l'option -d permet de lancer la stack en tache de fond)
- `docker-compose ps` : Permet de voir le **status** de l'ensemble de la stack
- `docker-compose logs -f` : Permet d'afficher les **logs** de la stack (`--tail n` pour afficher les n dernières lignes)
- `docker-compose stop` : Permet d'**arrêter** l'ensemble des services de la stack
- `docker-compose down` : Permet de **détruire** l'ensemble des ressources de la stack
- `docker-compose config` : Permet de **vérifier** la syntaxe d'un fichier *docker-compose.yml* 


## Docker Swarm


## Kubernetes



## To do 

- Pour IPFS : 1 seule image ou 1 stack (go-ipfs + stack)
- Une ou deux images/stack ? (admin + users)
- Comparer Docker Swarm et Kubernetes
- Automatisation de l'image de Johan