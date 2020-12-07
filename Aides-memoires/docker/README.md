Docker
======


## Architecture Docker

- **Docker Registry** : Contient les *images* (lecture seule).
- **Docket Host** : Contient le *docker engine*, les *images locales* et les différents *conteneurs* (chacun étant l'instance d'une image).
- **Docker Client** : Permet de se connecter au *docker engine* pour gérer l'exécution des *conteneurs*.

> Ces éléments peuvent ou pas être sur la même machine physique.


## Images

### Préambule

Une image est un empilement de couches en lecture seule. Par exemple, pour un serveur *nginx*, on aura une couche correspondant à l'OS (*debian* par exemple) et une couche correspondant à l'application (*nginx*). Lorsqu'un conteneur est créé à partir d'une image, on ajoute par dessus une couche en lecture-écriture qui vivra aussi longtemps que le conteneur. On a un fonctionnement de type *COW (copy-on-write)* c'est-à-dire que si le conteneur veut modifier un fichier d'une couche base, il va d'abord le copier dans la couche haute en lecture-écriture puis le modifier. 

On note que si on *pull* deux conteneurs qui utilisent une couche en commun, *Docker* ne va télécharger qu'une seule fois la couche en question.

### Création d'une image

#### A partir d'un conteneur
A partir d'un conteneur arrêté :
```
$ docker commit <cont_name> <new_image_name>
```

> Le nom de l'image créée est de la forme : `mon_organisation/mon_image:version`.

#### A partir d'un *Dockerfile*
Pour créer une image à partir d'un *Dockerfile* :
```
$ docker build -t <new_image_name> <path_to_folder_containing_dockerfile>
```

Les commandes de bases d'un *Dockerfile* :

- `FROM` : définit la couche de base de l'image.
- `LABEL` : permet de spécifier des informations sur la version, la description, etc.
- `ENV` : permet de définir une variable d'environnement.
- `RUN` : exécute une commande (ne pas utiliser ça pour l'application principale).
- `ADD` : copier (ou extrait une archive) depuis le répertoire de travail de l'hôte vers le conteneur. On peut utiliser des URL.
- `COPY` : copier simplement un fichier depuis le répertoire de travail de l'hôte vers le conteneur.
- `CMD` : spécifie la commande de l'application principale du conteneur. Elle n'existe qu'une seule fois dans un *Dockerfile*.
- `ENTRYPOINT` : le point d'entrée du conteneur (application principale). Si `CMD` est spécifiée aussi, il sert à surcharger la commande `ENTRYPOINT`.

Des bonnes pratiques : <https://docs.docker.com/develop/develop-images/dockerfile_best-practices/>

#### A partir d'une archive de conteneur
Pour créer une archive de conteneur (on peut ensuite compresser l'archive avec *gzip*) :
```
$ docker export -o <archive_filename.tar> <cont_name>
```

Pour générer une nouvelle image à partir de l'archive de conteneur :
```
$ docker import <archive_filename.tar.gz> <new_image_name>
```

> Dans ce cas, l'image créée ne comporte qu'une couche de base.

### Commandes

Lister les images disponibles en local :
```
$ docker images
```

Faire une recherche par mot-clé sur le *docker registry* public :
```
$ docker search <keyword>
```

Pour télécharger une image depuis le *docker registry* :
```
$ docker pull <image_name>
```

> Si on veut une version particulière de l'image, on peut spécifier un *tag* : `$ docker pull <image_nale>:<tag_name>`

Pour supprimer une image :
```
$ docker rmi <image_name>
```

Pour afficher les différentes couches d'une image :
```
$ docker history <image_name>
```


## Conteneurs

> C'est le contexte par défaut de la commande `docker` : `$ docker run` est équivalent à `$ docker container run`.

Un conteneur peut indifféremment être identifié par son nom ou son id.

Pour lancer l'exécution d'un conteneur (à partir d'une image) :
```
$ docker run <image_name>`
```

Pour lancer un conteneur en exécutant une autre commande que la commande par défaut du conteneur :
```
$ docker run <image_name> <command>
```

> Ne pas oublier que l'exécution du conteneur s'arrête en même temps que la commande spécifiée (ou en même temps que la commande par défaut si aucune commande n'est spécifiée).

Quelques options pour `docker run` :

- `--name=<cont_name>` : pour spécifier le nom du conteneur.
- `--host=<host_name>` : pour spécifier le nom de l'hôte associé au conteneur.
- `-d` : pour démarrer le conteneur en mode *détaché* (pas de connexion à un terminal)
- `-it` : pour se connecter à un shell interactif après le démarrage du conteneur ou laisse la possibilité de le faire si on a également spécifié l'option `-d`.
- `--restart=always` : relancer automatiquement le conteneur en cas de problème.

Pour lister les conteneurs en cours d'exécution :
```
$ docker ps
```

> Option `-a` : pour voir tous les conteneurs (même arrêtés).

Pour afficher la sortie standard d'un conteneur :
```
$ docker logs <cont_name>
```

Pour s'attacher à un conteneur (shell interactif) :
```
$ docker attach <cont_name>
```

Pour passer en mode *détaché* depuis le mode *attaché* : séquence de touches `[Ctrl]-p + q`.

Pour arrêter proprement un conteneur : ça envoie un signal *TERM* au processus principal du conteneur (PID 1) :
```
$ docker stop <cont_name>
```

Pour tuer un conteneur (moins proprement) :
```
$ docker kill <cont_name>
```

Pour démarrer un conteneur existant (conserve les paramètres passés lors du `docker run`) :
```
$ docker start <cont_name>
```

Pour mettre un conteneur en pause :
```
$ docker pause <cont_name>
```

> `docker unpause` pour reprendre l'exécution d'un conteneur en pause.

Pour supprimer un conteneur arrêté :
```
$ docker rm <cont_name>
```

Pour exécuter un processus à l'intérieur d'un conteneur :
```
$ docker exec <cont_name> <command>
```

> Les nouveaux processus sont créés à partir du PID 5 et ne seront pas tués en cas de `docker stop`. Il ne faut donc pas utiliser `docker exec` pour lancer l'application principale mais uniquement pour des processus annexes.

Pour obtenir des informations sur un conteneur (format json) :
```
$ docker inspect <cont_name>
```

> On peut extraire un champ particulier avec l'option `--format`. Par exemple pour l'IP du conteneur :
```
$ docker inspect --format='{{.NetworkSettings.IPAddress}}' <cont_name>
```

Pour voir les différences entre une image et un conteneur créé à partir de cette image :
```
$ docker diff <cont_name>
```

## Volumes

### Volumes nommés et anonymes

Créer un volume nommé :
```
$ docker volume create --name <volume_name>
```

Lister les volumes existants :
```
$ docker volume ls
```

Monter un volume nommé au démarrage d'un conteneur :
```
$ docker run -v <volume_name>:<mount_point_in_container> <image_name>
```

> Si on ne met pas le nom du volume, Docker va alors créer un *volume anonyme* qui sera automatiquement affecté au conteneur créé.

Voir les informations d'un volume :
```
$ docker volume inspect <volume_name>
```

Supprimer un volume (il ne doit être utilisé dans aucun conteneur) :
```
$ docker volume rm <volume_name>
```

> Les volumes sont regroupés dans le dossier `/var/lib/docker/volumes` de l'hôte.

### Volumes d'hôtes

Dans ce cas, on peut monter un dossier (ou simplement un fichier) de l'hôte vers un conteneur.

Au démarrage d'un conteneur :
```
$ docker run -v <host_path>:<container_path> <image_name>
```

### Volumes partagés

Il suffit de monter le même volume dans les conteneurs qui doivent y avoir accès. 

**Attention :** C'est aux applications dans les conteneurs de gérer les concurrences d'accès aux ressources d'un volume partagé. *Docker* ne permet pas de le faire.


## Réseau

### Divers
A l'installation, *Docker* crée le bridge `docker0` sur la machine hôte. Au démarrage d'un conteneur, une interface réseau virtuelle `vethX` est ajoutée à ce bridge et liée à l'interface réseau `ethX` du conteneur. Par défaut, *Docker* fait du NAT pour les conteneurs (on dispose ainsi par exemple d'Internet dans les conteneurs si l'hôte est connecté). 

Pour lister les réseaux disponibles :
```
$ docker network ls
```

Pour avoir des informations détaillées sur un réseau :
```
$ docker network inspect <network_name>
```

Par exemple, pour créer un réseau bridge supplémentaire :
```
$ docker network create --driver bridge --subnet 10.1.0.0/16 --gateway 10.1.0.1 <bridge_name>
```

Pour faire fonctionner un conteneur sur un réseau spécifique :
```
$ docker run --net <network_name> <image_name>
```

> *Docker* gère l'attribution de l'adresse IP dans le réseau spécifié pour chaque conteneur. Par ailleurs, *Docker* fournit une résolution de noms basée sur le nom des conteneurs (et pas sur les éventuels hostnames affectés).

### Plusieurs interfaces sur un conteneur
Si on souhaite créer un conteneur avec plusieurs interfaces réseaux, il faut en déclarer une principale (avec `--net`) puis connecter le conteneur aux autres réseaux (on ne peut pas utiliser plusieurs fois `--net` au démarrage d'un conteneur) :
```
$ docker run --name <cont_name> --net <network1_name> <image_name>
$ docker network connect <network2_name> <cont_name>
```

### Mapping de ports (PAT)
Pour mapper un port de l'hôte vers un port du conteneur :
```
$ docker run -p <ip_host>:<host_port>:<container_port> <image_name>
```

> Si `<ip_host>` n'est pas spécifiée, le mapping se fait pour toutes les interfaces de l'hôte (`0.0.0.0`).

Pour avoir des informations sur le mapping d'un conteneur :
```
$ docker port <cont_name>
```

On peut faire un mapping dynamique. Dans ce cas, c'est *Docker* qui choisit des ports aléatoires sur l'hôte et les mappe vers les ports exposés du conteneur. Il suffit d'utiliser l'option `-P` dans la commande `docker run`. Le mapping ne se fait que si le fichier `Dockerfile` contient au moins une directive `EXPOSE`.

