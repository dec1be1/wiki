Docker
======


## Architecture Docker

- **Docker Registry** : Contient les *images* (lecture seule).
- **Docket Host** : Contient le *docker engine*, les *images locales* et les différents *conteneurs* (chacun étant l'instance d'une image).
- **Docker Client** : Permet de se connecter au *docker engine* pour gérer l'exécution des *conteneurs*.

> Ces éléments peuvent ou pas être sur la même machine physique.


## Images

### Préambule

Une image est un empilement de couches en lecture seule. Par exemple, pour un serveur *nginx*, on aura une couche correspondant à l'OS (*debian* par exemple) et une couche correspondant à l'application (*nginx*). Lorsqu'un conteneur est créé à partir d'une image, les systèmes de fichiers de chaque couche sont réunis (*union filesystem*) et on ajoute par dessus une couche en lecture-écriture qui vivra aussi longtemps que le conteneur. On a un fonctionnement de type *COW (copy-on-write)* c'est-à-dire que si le conteneur veut modifier un fichier d'une couche base, il va d'abord le copier dans la couche haute en lecture-écriture puis le modifier. 

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
- `VOLUME` : spécifie un volume en dehors de l'*union filesystem* du conteneur.
- `CMD` : spécifie la commande de l'application principale du conteneur. Elle n'existe qu'une seule fois dans un *Dockerfile*. La commande s'exécute dans un shell : `/bin/sh -c CMD`.
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
- `-u 0` : pour forcer la connexion au conteneur en utilisateur `root`.
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

Pour passer en mode *détaché* depuis le mode *attaché* : séquence de touches `[Ctrl]+p+q`.

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

> On peut extraire un champ particulier avec l'option `--format` (format *Go Template*). Par exemple pour l'IP du conteneur :
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

### Volumes d'hôtes (*bind-mount*)

Dans ce cas, on peut monter un dossier (ou simplement un fichier) de l'hôte vers un conteneur.

Au démarrage d'un conteneur :
```
$ docker run -v <host_path>:<container_path> <image_name>
```

### Volumes partagés

Il suffit de monter le même volume dans les conteneurs qui doivent y avoir accès. 

**Attention :** C'est aux applications dans les conteneurs de gérer les concurrences d'accès aux ressources d'un volume partagé. *Docker* ne permet pas de le faire.


## Réseau

### Généralités

A l'installation, *Docker* crée le bridge `docker0` sur la machine hôte. Par défaut au démarrage d'un conteneur, une interface réseau virtuelle `vethX` est ajoutée à ce bridge et liée à l'interface réseau `ethX` du conteneur. Cela permet aux conteneurs de communiquer entre eux. Par défaut, *Docker* fait du NAT pour les conteneurs (on dispose ainsi par exemple d'Internet dans les conteneurs si l'hôte est connecté). 

En plus de l'interface brige `docker0`, *Docker* créé deux autres réseaux :

- *Host* : Si un conteneur est connecté à ce réseau, il utilisera la pile réseau de l'hôte.
- *None* : Si un conteneur est connecté à ce réseau, il ne disposera que de son interface *localhost* (pas de connexion avec l'extérieur).

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

> *Docker* gère l'attribution de l'adresse IP dans le réseau spécifié pour chaque conteneur. Par ailleurs, dans le cas d'un *user defined bridge* (donc pas le bridge par défaut `docker0`), *Docker* fournit une résolution de noms basée sur le nom des conteneurs (et pas sur les éventuels hostnames affectés).

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

### Drivers

Il existe nativement trois drivers pour les interfaces :

- *bridge* (par défaut) : Fournit une communication entre des conteneurs situés sur le même hôte.
- *overlay* : Permet la communication entre des conteneurs situés sur des hôtes différents (basé sur les fonctionnalités *VXLAN* du noyau Linux). Il ne peut être créé que dans le contexte d'un cluster d'hôtes *Docker* (par exemple *Swarm*).
- *macvlan* : Mapper directement l'interface réseau d'un conteneur vers une interface réseau de l'hôte(pas de bridge entre les deux). Utilisé principalement pour les performances. 

## Autres utilitaires

### docker-machine

Gestion du cycle de vie (création, démarrage, arrêt, ...) d'un hôte physique ou virtuel hébergeant *Docker* (démon *docker* et client). Il existe beaucoup de drivers pour des infrastructures locales (*virtualbox*, *vmware*) ou dans le cloud (*Amazon EC2*, *DigitalOcean*, ...).

On peut configurer le client local pour cibler un démon distant particulier (à l'aide de variables d'environnement). Voir `docker-machine env`.

### docker-compose

Gestion du cycle de vie d'une application multi-conteneurs (micro-service). Il utilise un fichier *yaml* (`docker-compose.yml`) qui décrit l'application :

- Les différents *services*. Chaque service permettra d'instancier un conteneur (ou plusieurs identiques en cas de réplication).
- Les volumes de données nécessaires.
- Les différents réseaux utilisés par les conteneurs.
- Le déploiement dans un cluster *Swarm* (à partir de la version 3 de *docker-compose*).

On peut avoir plusieurs versions de `docker-compose.yml` pour une application. Par exemple une version locale pour un environnement de développement et une version décrivant un déploiement en cluster pour l'environnement de production.

### Swarm

#### Généralités

Voir `docker swarm --help` et `docker node --help`.

*Swarm* est intégré au *Docker Engine*. Le mode *Swarm* permet l'orchestration d'applications sur un cluster. Permet le déploiement d'applications au format *Docker Compose*.

Un peu de vocabulaire :

- *Node* : Hôte physique ou virtuel faisant partie du cluster *Swarm* (le *Docker Engine* est par conséquent installé sur le node).
- *Manager* : Node particulier qui orchestre les conteneurs et gère l'état du cluster. Il y en a généralement plusieurs de manière à avoir de la redondance en cas de panne du manager leader. Si le leader tombe en panne, un autre leader est élu pour prendre le relai (ce manager doit avoir été configuré auparavant comme manager *reachable* avec la commande `docker node promote <node_name>`).
- *Worker* : Node particulier qui exécute des conteneurs. 

> Par défaut, un manager est aussi un worker.

Un node peut avoir plusieurs états :

- *Active* : Le node peut recevoir de nouvelles tâches.
- *Pause* : Le node ne reçoit plus de nouvelles tâches mais continue les tâches en cours.
- *Drain* : Le node ne reçoit plus de nouvelles tâches et les tâches en cours sont schedulées sur d'autres nodes du cluster (des nodes à l'état *active*).

#### Services

Voir `docker service --help`

Comme pour *Docker Compose*, on a la notion de *service*. Un service va permettre d'instancier un ou plusieurs conteneurs (en cas de réplicat). La commande `docker service` permet de gérer le cycle de vie des services. Une fois créé, un service pourra être déployé sur le cluster (sur différents nodes du cluster en cas de réplication). 

Comme pour les conteneurs, on peut définir des volumes pour les services.

#### Stack

Voir `docker stack --help`.

Une stack est un groupe de services déployée à partir d'un fichier au format *Docker Compose*. Une stack peut également comporter des réseaux et des volumes. 

> La suppression d'une stack engendre la suppression de tous les services de la stack.

#### Secrets

Voir `docker secret --help`.

On a la possibilité de gérer des secrets qui pourront être utilisés par les services. Après déclaration d'un secret pour un service, ce secret sera accessible en clair pour le service pendant son exécution (dans `/run/secrets/<secret_name>` qui est monté en *tmpfs*).

## Sécurité

### AppArmor

C'est un module de sécurité de Linux (*LSM* pour *Linux Security Module*) qui implémente du MAC (*Mandatory Access Control*) en complément du DAC (*Discretionary Access Control*) habituel.

Il permet d'ajouter des droits d'accès supplémentaires basés sur les chemins d'accès aux ressources selon les applications (un profil de sécurité par application). 

*Docker* utilise un profil par défaut lors du lancement d'un conteneur. On peut le désactiver en passant l'option `--security-opt apparmor:unconfined` à l'exécution d'un conteneur.

### SELinux

C'est aussi un *LSM* implémentant du *MAC*. Il définit des sujets (utilisateur, application, processus) et des objets (répertoire, périphérique, ...) ainsi que des règles définissant les objets auquel un sujet a accès.

Sur un système hôte utilisant SELinux, on peut désactiver le labeling SELinux avec l'option `--security-opt label:disable` lors de l'exécution d'un conteneur.

> Pour lister les attributs SELinux : `ls -Z`.

### Capabilities

Les *capabilities* est une fonctionnalité du noyau Linux permettant d'accorder des permissions précises à un processus. Cela permet à un utilisateur non root d'exécuter une action particulière qui nécessite normalement les droits root.

*Docker* définit des *capabilities* par défaut aux conteneurs. Elles peuvent être modifiées à l'aide des options `--cap-add` et `--cap-drop`.

### Seccomp

*Seccomp* permet de filtrer les appels systèmes exposés par le noyau aux processus. 

*Docker* applique par défaut un profil *seccomp* lors du lancement d'un conteneur de manière à interdire certains appels système. On peut créer un profil personnalisé et le fournir à l'exécution d'un conteneur avec l'option `--security-opt seccomp:policiy.json`. 

### Content Trust

Il s'agit d'un mécanisme de signature d'images (ou plutôt du tag des images). Il peut être activé via une variable d'environnement : `export DOCKER_CONTENT_TRUST=1`. 

Dans ce cas, la signature du tag de l'image sera créée lors d'un push sur un registry. Seules les images signées peuvent être pull lorsque *Content Trust* est activé.
