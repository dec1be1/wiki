# Kubernetes

*Kubernetes* (*k8s*) est un orchestrateur de conteneurs (*docker* par exemple).
Il peut être installé sur une seule machine pour des tests ou sur un cluster de
machines physiques ou virtuelles.

La documentation officielle : <https://kubernetes.io/fr/docs/home/>

## Concepts de base

Les objets de base :

- *Pod* : Ensemble de conteneurs tournant sur un même node et partageant le
  réseau et le stockage. Un pod est la plus petite unité applicative de k8s.
- *Replicas* : Nombre d'instances d'un même pod.
- *Service* : Ensemble de pods identiques (incluant les pods répliqués).
- *ReplicaSet* : Objet permettant de s'assurer que les réplicats sont bien
  actifs.
- *Deployment* : Objet définissant l'état désiré d'une application.

## Architecture

Un cluster est composé de plusieurs nodes (machines physiques ou VMs). Il y a
deux types de nodes : *Master* et *Worker*.

### Node Master

Gestion du cluster (*control plane*). Il est le point d'entrée
des commandes d'administration. Il peut y en avoir plusieurs pour la HA.

Il exécute les processus suivants :

- `kube-apiserver` : Expose l'API REST de k8s.
- `kube-scheduler` : Ordonnance l'exécution des pods sur chacun des nodes
  worker en prenant en compte les ressources nécessaires et disponibles.
- `kube-controller-manager` : Ensemble d'éléments qui contrôlent par exemple
  l'état des nodes, le bon déploiement des applications, etc.
- `etcd` : *Key-Value store* distribué qui stocke les données d'un cluster
  (configuration, état, ...).

### Node Worker

Node sur lesquel sont exécutés les pods d'aune application.
Il communique avec le node master et fournit les ressources aux pods.

Les processus tournant sur un les nodes worker :

- `kubelet` : Agent qui tourne sur chaque node et assure la communication avec
  le master. Il s'assure que les conteneurs d'un pod tournent conformément à
  leur spécification.
- `kube-proxy` : Gère les connexions réseau des pods tournant sur le node
  (exposition des services, régles réseau).
- Environnement d'exécution de conteneurs : *Docker* ou autre.


## Autres briques logicielles

- `kubectl` : Client permettant de communiquer avec le cluster (via l'API).
- `minikube` : Outil permettant de déployer très facilement un cluster k8s
  sur un poste de travail à des fins de tests. L'installation se fait
  automatiquement dans une VM (différents hyperviseurs supportés).
- `helm` : Gestionnaire de packages pour *k8s*. Il permet d'installer des
  *Charts* (regroupent plusieurs fichiers de spécifications *k8s*).

On peut par exemple voir la configuration du cluster :
```
$ kubectl config view
```

## Objets (ou ressources)

Différentes catégories d'objet :

- Gestion des applications du cluster : *Pod*, *Deployment*, *ReplicaSet*, ...
- Service discovery et load balancing : *Service*, ...
- Configuration des applications : *ConfigMap*, *Secret*, ...
- Gestion du stockage : *PersistentVolume*, *PersistentVolumeClaim*, ...
- Configuration du cluster : *Namespace*, ...

Les objets sont représentés dans un fichier de description au format *yaml*.
On trouve des clés communes à tous les types d'objets :

- `apiVersion` : La version d'API à utiliser pour communiquer avec le cluster.
- `kind` : Le type d'objet.
- `metadata` : Des données relatives à l'objet.
- `spec` : Les spécifications de l'objet.

### Pod

Le pod représentate l'unité applicative de base dans k8s.
Il peut regrouper plusieurs conteneurs qui vont tourner dans le même contexte
d'isolation (*namespaces* Linux). Chaque pod dispose de sa propre adresse IP
et les conteneurs d'un même pod peuvent communiquer par le réseau via
l'interface *localhost*. Les stockages sont également partagés entre les
conteneurs d'un même pod.

Un pod est décrit par un fichier yaml. Un exemple simple d'un pod contenant
un seul conteneur nginx :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: www
  labels:
    app: www
spec:
  containers:
  - name: nginx
    image: nginx:1.12.2
```

> La clé `labels` ne sert pas ici mais sera utile à partir du paragraphe
> suivant sur les services.

On peut alors créer et démarrer le pod :
```
kubectl create -f www.yaml
```

On peut aussi démarrer rapidement un pod avec la commande suivante :
```
kubectl run <pod_name> --image=<_image_name>
```

Pour lister les pods en cours d'exécution :
```
kubectl get pods
```

Pour obtenir des informations détaillées sur un pod :
```
kubectl describe pod <pod_name>
```

Pour exécuter une commande dans un conteneurd'un pod (lancer un shell
interactif par exemple) :
```
kubectl exec -ti -c <container_name> <pod_name> -- bash
```

> Si on ne spécifie pas le conteneur, la commande est lancée sur le premier du
> pod.

Pour faire une redirection d'un port de l'hôte local vers un port du pod :
```
kubectl port-forward <pod_name> <host_port>:<pod_port>
```

Pour supprimer un pod :
```
kubectl delete pod <pod_name>
```

### Service

Un service permet de rendre l'application déployée dans un (ou plusieurs) pods
disponible à l'intérieur ou à l'extérieur du cluster. Sans service, les
applications tournant dans les pods sont inaccessibles.

Un service regroupe plusieurs instances de pods identiques et est responsable
de la répartition de charge entre ces différents pods. Le regroupemet des pods
se fait à l'aide de *labels*.
De plus, un service dispose d'une adresse IP résolue à l'aide de son nom.

Il existe différents types de service :

- *ClusterIP* : Permet d'exposer des pods à l'intérieur du cluster (à
  disposition d'autres pods). C'est le service par défaut.
- *NodePort* : Permet d'exposer des pods à l'extérieur du cluster.
- *LoadBalancer* : Disponible uniquement sur certains *Cloud Provider*.
- *ExternaName* : Permet de définir un alias vers un service extérieur au
  cluster.

Exemple de fichier de spécification d'un service permettant d'exposer les pods
ayant le label `app: www` sur le port 80 à l'adresse IP du service (résolue
par le nom du service). On crée également une redirection entre ce port et le
port 80 du serveur web tournant dans les pods :
```yaml
apiVersion: v1
kind: Service
metadata:
  name: www
spec:
  selector:
    app: www
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
```

> Le service est ici de type *ClusterIP*. Il ne sera donc accessible que
> depuis l'intérieur du cluster pour les autres pods.

On peut créer et démarrer le service :
```
kubectl create -f www_svc_clusterIP.yaml
```

On peut lister les services :
```
kubectl get svc
```

Avoir des informations détaillées sur un service :
```
kubectl describe svc <service_name>
```

Pour obtenir les spécifications d'un service :
```
kubectl get svc <service_name> -o yaml
```

Supprimer un service :
```
kubectl delete svc <service_name>
```

> Le type de service *NodePort* permet d'exposer l'application tournant dans
> les pods du service sur un port (à spécifier en plus avec la clé `nodePort`)
> de chaque nodes du cluster. On pourra ainsi y accéder depuis l'extérieur du
> cluster. L'accès est touojours possible depuis l'intérieur du cluster comme
> avec un service de type *ClusterIP*.


### Deployment

Un *Deployment* permet de créer et gérer des pods. Lorsqu'on crée un
*Deployment*, un objet de type *ReplicaSet* est également créé. Il est
responsable de vérifier en permanence que le nombre de pods en cours
d'exécution est conforme à la spécification définie dans le *Deployment*
(état souhaité : spécification d'un pod et nombre de réplicas).

> Dans la pratique, les pods sont généralement créés à l'aide d'un
> *Deployment* et gérés par le *ReplicaSet* associé.

Un exemple de spécification de *Deployment* :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: www-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: www
  template:
    metadata:
      labels:
        app: www
    spec:
      containers:
      - name: nginx
        image: nginx:1.12.2
        ports:
        - containerPort: 80
```

On peut mettre en évidence trois parties :

1. Description du *Deployment* (version API, type et nom).
2. Description du *Replicaset* (nombre de réplicas et label des pods à
regrouper).
3. Description du template de *Pod* (label et spécifications).

On peut créer et démarrer un *Deployment* :
```
kubectl create -f www_deploy.yaml
```

On peut lister les *Deployments* :
```
kubectl get deploy
```

On peut lister les *ReplicaSets*
```
kubectl get rs
```

Pour avoir des informations détaillées sur un *Deployment* ou un
*ReplicaSet* :
```
kubectl describe deploy <deploy_name>
kubectl describe rs <rs_name>
```

> On peut ensuite créer un service qui permettra d'exposer les pods du
> *Deployment*, par exemple à l'extérieur du cluster avec un service
> *NodePort*. Il suffira de créer le service avec une clé *selector*
> correspondant au label des pods du *Deployment*.

#### Mise à jour d'un *Deployment*

Il existe plusieurs stratégies de mise à jour. On ne parlera ici que de la
stratégie de type *rolling update* qui permet de faire les mises à jour
petits à petits (pods par pods pour garantir une continuité de service).

Pour mettre à jour l'image utilisée par un conteneur :
```
kubectl set image deployment <deploy_name> <container_name>=<new_image_name>
```

> Pour chaque version de l'application, un nouveau *ReplicaSet* est créé.
> Il permet de gérer le démarrage des nouveaux pods mis à jour. Les
> *ReplicaSet* des pods à mettre à jour gèrent l'arrêt de ces pods.
> De plus, on note que les *ReplicaSet* qui géraient les pods arrêtés (car
> plus à jour) sont conservés et pourront être réutilisés en cas de rollback.

Pour voir l'historique des révisions d'un *Deployment* :
```
kubectl rollout history deployment <deploy_name>
```

Si une mise à jour se passe mal, on peut revenir en arrière :
```
kubectl rollout undo deployment <deploy_name> --to-revision=2
```

> Si on ne spécifie pas `--to-revision`, on revient à la révision précédente.

### Secret

L'objet *Secret* permet la protection de données sensibles et évite ainsi
d'avoir à stocker ces informations dans les images ou les fichiers de
spécifications.

Les secret sont créés soit par l'utilisateur (avec `kubectl`) soit
automatiquement par le systmèe. Ils sont stockés dans `etcd`.

Il existe plusieurs types de secret :

- *generic* : Créé à partir d'un fichier, d'un répertoire ou d'une valeur.
- *docker-registry* : Permet de s'authentifier auprès d'un registry.
- *TLS* : Permet de gére rune clé privée et son certificat.

Plusieurs données peuvent être stockées dans un seul secret (par exemple
un identifiant et un mot de passe).

#### Secret *generic*

Pour créer un secret *generic* à partir de valeurs littérales :
```
kubectl create secret generic <secret_name> \
  --from-literal=<secret1_key>=<secret1_value> \
  --from-literal=<secret2_key>=<secret2_value> \
```

> On peut aussi faire depuis un fichier avec `--from-file`.
> Il est également possible de définir un secret depuis un fichier de
> spécifications (`kind: Secret`) et de le créer avec `kubectl create -f`.

On peut alors lister les secrets existants :
```
kubectl get secrets
```

On peut aussi récupérer les spécifications :
```
kubectl get secret <secret_name> -o yaml
```

> **Attention** : Les secrets peuvent apparaître seulement encodés en base64.

On peut ensuite utiliser les secrets dans un pod en déclarant un volume et
en spécifiant le secret à monter. Par exemple :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine
spec:
  containers:
  - name: alpine
    image: alpine
    command:
    - "sleep"
    - "10000"
    volumeMounts:
    - name: creds
      mountPath: "/etc/creds"
      readOnly: true
  volumes:
  - name: creds
    secret:
      secretName: <secret_name>
      - key: <secret1_key>
        path: service/user
      - key: <secret2_key>
        path: service/pass
```

Les secrets seront alors disponibles dans le pod aux paths suivants :

- `/etc/creds/service/user`
- `/etc/creds/service/pass`

> On peut aussi rendre les secrets disponibles dans les pods via des variables
> d'environnement.

#### Secret *docker-registry*

On peut créer un secret qui permettra de s'authentifier lorsqu'on fait un
pull d'une image privée depuis un registry docker :
```
kubectl create secret docker-registry <secret_name> \
  --docker-server=<registry_fqdn>
  --docker-username=<username>
  --docker-password=<password>
  --docker-email=<email>
```

On déclare ensuite le secret dans le fichier de spécification du pod :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: <private_image_name>
spec:
  containers:
  - name: <container_name>
    image: <my_private_image_name>
  imagePullSecrets:
  - name: <secret_name>
```

#### Secret *TLS*

Ce type de secret permet des gérer des couples *certificat/clé privée* par
exemple dans le cadre d'un pod hébergeant un serveur web en https.

Pour créer ce type de secret :
```
kubectl create secret tls <secret_name> \
  --cert <cert_filename> \
  --key <private_key_filename>
```

On le rend ensuite disponible dans un pod en définissant la spécification :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webserver
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    volumeMounts
    - name: tls
      mountPath: "/etc/ssl/certs/"
  volumes:
  - name: tls
    secret:
      secretName: <secret_name>
```

Le certificat et la clé privée seront alors disponibles dans le pod au path
`/etc/ssl/certs/`.


### ConfigMap

Un objet de type *ConfigMap* permet de gérer la configuration d'une
application en découplant cette configuration du code de l'application.

Une *ConfigMap* peut être créée à partir d'un fichier (configuration ou
environnement) ou de valeurs littérales. L'objet *ConfigMap* contient une ou
plusieurs paires de type *clé/valeur*.

Pour voir le détail d'une *ConfigMap* :
```
kubectl get cm <configmap_name> -o yaml
```

#### Création

##### Depuis un fichier de configuration

```
kubectl create configmap <configmap_name> --from-file=<config_filename>
```

Dans ce cas, l'objet contiendra une seule paire clé/valeur. La clé correspond
au nom du fichier de configuration et la valeur à son contenu.

##### Depuis un fichier d'environnement

```
kubectl create configmap <configmap_name> --from-env-file=<env_filename>
```

Les paires clé/valeur contenues dans le fichier d'environnement sont alors
présentes dans la *ConfigMap* créée.

##### Depuis des valeurs littérales

```
kubectl create configmap <configmap_name> \
  --from-literal=<key1>=<value1>
  --from-literal=<key2>=<value2>
  --from-literal=<key3>=<value3>
```

Les paires clé/valeur définies sont présentes dans la *ConfigMap* créée.

#### Accès depuis un pod

On peut accéder à une *ConfigMap* dans un pod en indiquant dans sa
spcification un volume référençant la *ConfigMap* et en montant ce volume.
Par exemple :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: www
spec:
  containers:
  - name: www
    image: nginx:1.14.2
    volumeMounts:
    - name: config
    mountPath: "/etc/nginx/"
  volumes:
  - name: config
    configMap:
      name: <configmap_name>
```

On peut aussi définir des variables d'environnement dans un pod à partir des
paires clé/valeur d'une *ConfigMap* :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: www
spec:
  containers:
  - name: www
    image: nginx:1.14.2
    env:
    - name: <env_variable_name_in_pod>
      valueFrom:
        configMapKeyRef:
          name: <configmap_name>
          key: <key_name_in_configmap>
```

### Namespace

Les *Namespaces* permettent de créer des groupes d'objets dans un cluster.
Cela permet donc de segmenter un cluster pour pouvoir par exemple le partager
entre plusieurs entités.

Pour lister les namespaces du cluster :
```
kubectl get namespaces
```

> Il existe un namespace par défaut (*default*) dans lequel les ressources
> sont créées si aucun namespace n'est spécifié.

Pour créer ou supprimer un namespace :
```
kubectl create namespace <namespace_name>
kubectl delete namespace <namespace_name>
```

> **Attention** : La suppression d'un namespace entraîne la suppression de
> tous les objets de ce namespace.

On peut aussi utiliser un fichier de spécification (on ajoute ici un label) :
```yaml
apiVersion: v1
kind: Namespace
metadata:
  - name: <namespace_name>
    labels:
      name: <label_name>
```

On crée alors le namespace avec `kubectl create -f`.

#### Utilisation

Par exemple pour un pod (vrai pour les autres types d'objet), on peut
indiquer le namespace dans le fichier de spécification avec la clé
`metadata.namespace`.

On peut également spécifier le namespace au démarrage du pod :
```
kubectl run <deployment_name> --namespace <namespace_name> ...
```

Pour lister les pods d'un namespace avec `--namespace` ou `-n` :
```
kubectl get deploy,pods --namespace <namespace_name>
```

> On peut utiliser `--all-namespaces` ou `-A` pour lister les objets de tous
> les namespaces en même temps.

#### Contexte

Le contexte est défini par :

- Le cluster sur lequel on se trouve.
- Le namespace par défaut (*default* à l'installation de k8s).
- Un utilisateur.

Il est possible de modifier le namespace par défaut du contexte courant :
```
kubectl config set $(kubectl config current-context) \
  --namespace=<namespace_name>
  ```

### Ingress

Cet objet représente un ensemble de règles permettant d'exposer un
service à l'extérieur du cluster. C'est donc une manière alternative à
un service de type *NodePort* pour exposer une application.

Son utilisation nécessite l'installation d'un *Ingress Controller*.

> Pour utiliser *Ingress* avec *Minikube*, il est nécessaire d'activer un
> module avec la commande `minikube addons enable ingress`.

### Volume

Un volume permet de découpler les données du cycle de vie d'un pod (ou d'un
conteneur).

#### Volume de type *EmptyDir*

Ce type de volume est lié au cycle de vie d'un pod mais découplé de celui
des conteneurs de ce pod. En d'autres termes :

- Le volume est créé au démarrage d'un pod et peut être rendu disponible dans
  les conteneurs du pod (éventuellement à des points de montage différents).
- Le volume est vide au démarrage du pod.
- Le volume est perdu lors de l'arrêt d'un pod.
- Si un conteneur du pod crashe, k8s va le détecter et redémarrer le
  conteneur. Dans ce cas, le volume persiste et le nouveau conteneur
  retrouvera les données manipulées par celui qui a crashé.

Exemple de définition d'un volume *EmptyDir* dans la spécification d'un pod :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine
spec:
  containers:
  - image: alpine
    name: alpine
    volumeMounts:
    - mountPath: /data
      name: data
  volumes:
  - name: data
    emptyDir: {}
```

#### Volume de type *hostPath*

On monte ici une ressource de la machine hôte dans le ou les conteneurs d'un
pod. On peut monter différents types de ressources : répertoire, fichier,
socket, char device, block device.

Par exemple, pour monter le répertoire `/data` de l'hôte dans le répertoire
`/var/data` du conteneur *alpine* du pod *alpine* :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine
spec:
  containers:
  - image: alpine
    name: alpine
    volumeMounts:
    - mountPath: /var/data
      name: data
  volumes:
  - name: data
    hostPath:
      path: /data
```

#### Volume de type *Persistent*

On ajoute ici une couche d'abstraction pour la gestion des volumes.

L'utilisation de ce type de stockage se fait en trois étapes :

1. Création d'un *PersistentVolume* : Permet de définir le type de stockage
   (NFS, iSCSI, GCEPersistentDisk, AWSElasticBlockStore, Ceph, ...), la
   capacité, le mode d'accès, le chemin sur le système de stockage, ...
2. Création d'un *PersistentVolumeClaim* : Représente une demande stockage
   afin de consommer un *PersistentVomlume*. On y spécifie des contraintes
   supplémentaires (taille, mode d'accès, ...).
3. Création d'un pod utilisant un *PersistentVolumeClaim*.

On peut créer les *PersistentVolume* et les *PersistentVolumeClaim* dans des
fichiers de spécifications *yaml* puis en utilisant, comme pour les autres
ressources, la commande `kubectl create -f`.

On peut lister ces objets avec les commandes :
```
kubectl get pv,pvc
```

## Droits d'accès

Les droits d'accès à l'API server (*HTTP REST*) sont gérés par un mécanisme
d'authentification et d'autorisation des utilisateurs.

### Authentification

#### Utilisateur normal

L'identification se fait en envoyant un nom d'utilisateur et un ou plusieurs
groupes.

Il existe plusieurs méthodes pour authentifier une requête. Par exemple :

- *Certificat client* : Le client envoie son certificat qui aura d'abord été
  signé avec la clé privée du CA du cluster.
- *Bearer token* : On passe un token dans le header *Authorization* de la
  requête HTTP.
- *HTTP basic auth* : Idem que *bearer token* mais on passe une chaîne
  *login:password* encodée en base64.
- *Proxy* : Dans ce cas, l'utilisateur s'authentifie sur le proxy et c'est ce
  dernier qui se charge d'ajouter les headers d'authentification pour l'API
  server (délégation d'authentification au proxy).

Par exemple, pour la gestion par *certificat client* :

1. Création d'une clé privée et d'une CSR pour l'utilisateur. Le champ `CN`
   du certificat indique le nom d'utilisateur et le champ `O` indique le ou
   les groupes.
2. Signature de la CSR de l'utilisateur par la CA du cluster.
3. Ajout d'une entrée *user* dans la configuration du cluster avec
   `kubectl config set-credentials`.
4. Création d'un nouveau contexte pour l'utilisateur avec
   `kubectl config set-context`.

Pour lister les contextes du cluster :
```
kubectl config get-contexts
```

> L'authentification est créée. Il faut maintenant créer les autorisations.

#### Process d'un pod

Les process d'un pod peuvent être amenés à faire des requêtes à l'API server.
Dans ce cas, ils utilisent un objet de type *ServiceAccount*. Par défaut,
chaque pod dispose d'un *ServiceAccount*.

Pour les lister :
```
kubectl get sa --all-namespaces
```

### Autorisation

*k8s* implémente un mécanisme *RBAC* (*Role-Based Access Control*) : il s'agit
de règles définissant l'accès aux ressources du cluster et s'appliquant aux
utilisateurs, groupes et *ServiceAccount*.

Quatre types d'objet entrent en jeu :

- *Role* : Permet de définir des règles dans un *namespace*.
- *ClusterRole* : Permet de définir des règles dans l'ensemble du cluster (pas
  seulement par rapport à un *namespace*).
- *RoleBinding* : Permet d'associer des objets de type *Role* à des
  utilisateurs, groupes ou *ServiceAccount*.
- *ClusterRoleBinding* : Permet d'associer des *ClusterRole* à des
  utilisateurs, groupes ou *ServiceAccount*.

Chacun de ces objets est défini dans un fichier de spécifications *yaml*.
On crée ensuite l'objet dans le cluster avec la commande `kubectl create -f`.
