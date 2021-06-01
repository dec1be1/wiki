Installation GitLab sur serveur Debian
======================================

On propose ici d'installer une instance de *Gitlab CE* sur un système
Debian 10 (Buster). Le serveur se trouve derrière un reverse proxy qui
gèrera notamment les connexions TLS vers l'extérieur. L'interface web de notre
instance *Gitlab* écoutera donc seulement sur le port 80. L'installation du
reverse proxy n'est pas détaillée ici.

## Installation

### Pré-requis

Le serveur (ou la VM) doit avoir au minimum :

- 4 coeurs
- 4GB de RAM

On installe les pré-requis :
```
# apt install curl vim openssh-server ca-certificates
```

### Serveur mail

Gitlab doit pouvoir envoyer des mails. On choisit ici d'installer *Postfix*
sur le serveur. On suit le tutoriel suivant :
<https://computingforgeeks.com/install-and-configure-postfix-smtp-server-on-debian/>

> Note : le serveur `git.example.com` doit disposer d'un enregistrement de
  type A dans la zone DNS.

### Ajout du dépôt Gitlab CE

On peut utiliser le script suivant :
```
# curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
```

### Installation du paquet

On précise l'adresse externe du serveur web (ici https://git.example.com) et
on installe le paquet :
```
# export GITLAB_URL="https://git.example.com"
# EXTERNAL_URL="${GITLAB_URL}" apt install gitlab-ce
```

## Configuration

A ce stade, le serveur web n'est pas accessible à cause d'un problème de
redirection. Il est nécessaire de préciser la configuration. On édite le
fichier `/etc/gitlab/gitlab.rb` :
```
external_url 'https://git.example.com'
nginx['listen_port'] = 80
nginx['listen_https'] = false
```

On relance la configuration :
```
# gitlab-ctl reconfigure
```

On peut alors accéder à l'interface web : <https://git.example.com>


## Sources

* <https://computingforgeeks.com/how-to-install-and-configure-gitlab-ce-on-debian-buster/>
* <https://www.itsfullofstars.de/2019/06/gitlab-behind-a-reverse-proxy/>
