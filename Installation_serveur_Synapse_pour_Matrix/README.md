Installation serveur Synapse (Matrix) sous Debian
=================================================

Le principe est d'installer un reverse proxy TLS (*nginx* ici) qui va transférer les requêtes venant :
- des clients : du port 443 du reverse proxy vers le port 8008 local du serveur *synapse*
- des autres serveurs *Matrix* (fédération) : du port 8448 du reverse proxy vers le port 8008 local du serveur *synapse*

On doit donc ouvrir les ports 443 et 8448 (en TCP) sur le firewall du serveur.

*Certbot* va gérer le renouvellement du certificat TLS.

> Note : A l'heure de la rédaction de cet article, *synapse* ne gère pas la version 2 du protocole *ACME*. On ne peut donc pas utiliser la fonction de gestion des certificats intégrée dans *synapse*. On gère donc avec une installation séparée de *Certbot*.


## Pré-requis
### Paquets
```
# apt install build-essential python3-dev libffi-dev python3-pip python3-setuptools sqlite3 libssl-dev python3-virtualenv libjpeg-dev libxslt1-dev virtualenv
```

### certbot
On fait une installation classique de *certbot* de manière à générer un certificat et le mettre à jour régulièrement. Ce certificat sera uniquement à disposition du serveur *nginx* qui fait reverse proxy (le serveur *synapse* tournant uniquement en local et recevant les requêtes depuis le reverse proxy).

### nginx
On fait une installation classique de *nginx* qui va servir de reverse proxy pour prendre en charge les requêtes sur les ports 443 et 8448 exposés sur internet.

### node
Il faut une version récente de nodejs (à l'heure de l'écriture de cet article, la version dans *debian stable* n'est pas suffisante). J'ai pris l'archive précompilée (en version LTS) disponible sur le site https://nodejs.org. Pour l'installation : https://github.com/nodejs/help/wiki/Installation.

Peut-être plus simple (à tester) : https://github.com/nodesource/distributions/blob/master/README.md.

### PostgreSQL
On peut en complément installer *PostgreSQL* pour de meilleures performances : https://wiki.debian.org/PostgreSql puis https://github.com/matrix-org/synapse/blob/master/docs/postgres.md.

## Installation
Sur Debian 10, on peut installer par les paquets disponibles dans les dépôts :
```
# apt install matrix-synapse
```

Alternativement, on peut installer via les sources en suivant les indications ici : https://github.com/matrix-org/synapse/blob/master/INSTALL.md




## Installation des bridges
### IRC

Commencer par créer un fichier `passkey.pem`.

Editer le fichier `config.yaml` :
- Entrer la configuration du serveur IRC qu'on veut mettre à disposition
- Mettre le chemin du fichier `passkey.pem`
- Configurer la base de données à utiliser

Commande pour créer un fichier de *registration* :
```
$ node app.js -r -f my_registration_file_freenode.yaml -u "http://localhost:9998" -c config.freenode.yaml -l my_bot
```

Enregistrer le service dans le fichier de configuration de synapse `homeserver.yaml` (section `app_service_config_files`).
Relancer synapse (`$ synctl restart` à lancer dans l'environnement virtuel Python).

Commande pour lancer un *appservice* :
```
$ node app.js -c config.freenode.yaml -f my_registration_file_freenode.yaml -p 9998
```


* https://github.com/matrix-org/matrix-appservice-irc
* https://github.com/matrix-org/matrix-appservice-irc/blob/master/HOWTO.md
* https://wiki.calculate-linux.org/matrix_irc_bridge
* https://github.com/matrix-org/matrix-appservice-irc/wiki


### Discord


### Whatsapp
