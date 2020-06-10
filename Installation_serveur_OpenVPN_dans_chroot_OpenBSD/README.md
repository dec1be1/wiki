Installation d'un serveur OpenVPN dans un chroot sous OpenBSD
=============================================================

Cette page décrit la procédure à suivre pour installer *OpenVPN* dans un chroot sur *OpenBSD*.

## Installation et configuration
### Installation des paquets et création des répertoires
Pour installer les paquets (on va utiliser *easy-rsa* pour faciliter la gestion des certificats) :
```
# pkg_add openvpn easy-rsa
```

Création des répertoires nécessaires et du chroot qui sera dans `/var/openvpn/chrootjail` :
```
# install -m 700 -d /etc/openvpn/private
# install -m 700 -d /etc/openvpn/private-client-conf
# install -m 755 -d /etc/openvpn/certs
# install -m 755 -d /var/log/openvpn
# install -m 755 -d /var/openvpn/chrootjail/tmp
# install -m 755 -d /var/openvpn/chrootjail/etc/openvpn
# install -m 755 -d /var/openvpn/chrootjail/var/openvpn
# install -m 755 -d /var/openvpn/chrootjail/etc/openvpn/ccd  # client custom configuration dir
# ln -s /var/openvpn/chrootjail/etc/openvpn/ccd/ /etc/openvpn/
```

On note que, dans le cas d'une exécution dans un chroot, les deux éléments suivants doivent être accessibles depuis le chroot :
* Dossier `ccd` (qui pourra contenir des fichiers de configuration spécifiques pour les clients).
* Fichier `crl.pem` (qui sera créé plus tard lors de la création de la pki.

On crée donc ces deux éléments à l'intérieur du chroot. Les éléments correspondants à l'extérieur du chroot sont donc des liens symboliques vers le chroot.

### Création de la pki avec easy-rsa
On utilise un script maison écrit selon le tuto suivi : [create-new-pki.sh](./create-new-pki.sh).
```
# ./create-new-pki.sh
```

### Création d'un mot de passe pour l'interface de management
*OpenVPN* dispose d'une interface de management. Elle ne doit pas être accessible depuis l'extérieur... le firewall doit bloquer les ports (a priori c'est déjà fait si le firewall est bien configuré). On peut ensuite accéder à l'interface de management via *telnet* sur le port 1195 depuis le serveur vpn lui-même (s'y connecter en ssh si nécessaire) :
```
# telnet localhost 1195
```

Pour la mise en place du mot de passe :
```
# test -f /etc/openvpn/private/mgmt.pwd || touch /etc/openvpn/private/mgmt.pwd
# chown root:wheel /etc/openvpn/private/mgmt.pwd; chmod 600 /etc/openvpn/private/mgmt.pwd
# vim /etc/openvpn/private/mgmt.pwd  # insert one line of text with clear-text password for management console
```

### Configuration du serveur OpenVPN
*OpenVPN* va tourner sur l'interface *tun0* avec le sous-réseau `10.8.0.0/24`. Un accès au réseau local (`192.168.0.0/24`) peut être fourni en poussant une route vers ce dernier aux clients (on ne le fait pas ici puisque la directive correspondante est commentée).

De plus, on force ici tout le trafic à passer par le vpn (directive `push "redirect-gateway def1"`), y compris les requêtes DNS. Il faut donc pousser un serveur DNS pour la résolution de nom : ici, un serveur DNS (ou un cache DNS comme par exemple *unbound*) doit tourner sur le serveur puisqu'on pousse l'adresse du serveur lui-même (`10.8.0.1`).

On crée puis on édite le fichier de configuration du serveur :
```
# test -f /etc/openvpn/server_tun0.conf || touch /etc/openvpn/server_tun0.conf
# chown root:_openvpn /etc/openvpn/server_tun0.conf; chmod 640 /etc/openvpn/server_tun0.conf
# vim /etc/openvpn/server_tun0.conf
```

Voilà un exemple de configuration : [/etc/openvpn/server_tun0.conf](./server_tun0.conf).

### Configuration du firewall
La configuration présentée ici est basique. Elle suffit pour une utilisation personnelle. Dans le cas d'un vpn multi-utilisateurs, une configuration plus fine est à envisager pour un meilleur contrôle d'accès.

La configuration du firewall sous OpenBSD ([Packet Filter](https://www.openbsd.org/faq/pf/index.html)) se fait dans le fichier `/etc/pf.conf`. Évidemment, avant toutes modifications dans ce fichier, on en fait une sauvegarde !

Toutes les lignes suivantes sont donc à insérer dans le fichier `/etc/pf.conf`.

On commence par ajouter quelques *macros* qui seront utiles (en début de fichier) :
```
tun_if="tun0"
vpn="10.8.0.0/24"
vpn_ports = "{ 1194 }"
```

Ensuite, on va *natter* le trafic provenant du vpn (à insérer à l'endroit des règles par défaut) :
```
match out on egress inet from { $vpn } to any nat-to (egress:0)
```

Puis, on autorise le trafic entrant sur l'interface du vpn (après la ligne précédente) :
```
pass in quick on $tun_if keep state
```

Enfin, on autorise le trafic venant de l'extérieur sur le port d'écoute du serveur vpn :
```
pass in quick on $ext_if inet proto tcp from !<abuse> to (egress) port $vpn_ports \
        flags S/SA keep state (max-src-conn 100, max-src-conn-rate 20/1, overload <abuse> flush global)
```

Quelques remarques supplémentaires sur cette ligne :
* On suppose ici que le vpn travaille en *tcp*.
* L'interface `$ext_if` correspond à l'interface connectée à *Internet*.
* La table `<abuse>` recueille les adresses ip des méchants brute-forceurs. Cette table est bien évidemment à déclarer en amont dans le fichier.

### Activation du routage de paquets sur le serveur
Mettre la ligne suivante dans le fichier `/etc/sysctl.conf` (créer le fichier s'il n'existe pas) :
```
net.inet.ip.forwarding=1
```

### Lancement d'OpenVPN au démarrage
On va configurer l'interface *tun0* en créant le fichier `/etc/hostname.tun0` :
```
# touch /etc/hostname.tun0 && chmod 640 /etc/hostname.tun0
```

On met le contenu suivant dedans :
```
up
group openvpn
description "OpenVPN tunnel"
!/usr/local/sbin/openvpn --config /etc/openvpn/server_tun0.conf & false
```

On peut alors activer l'interface :
```
# sh /etc/netstart tun0
```

Après tout ça, le serveur OpenVPN doit être opérationnel et se lancer correctement au démarrage.

### Gestion des utilisateurs
#### Template fichier configuration
Commencer par créer un fichier *template* pour les configurations des clients. Il sera placé dans [`/etc/openvpn/private/vpnclient.conf.template`](./vpnclient.conf.template).

#### Créer un utilisateur
On utilise un script fait maison : [create-vpn-user.sh](./create-vpn-user.sh).

Il crée un seul fichier de configuration pour un utilisateur sur la base du fichier *template* précédent. Ce fichier contient les informations pour la connexion ainsi que les certificats et clés nécessaires (que le script ajoute après les informations de connexion).

**Ce fichier doit donc rester secret puisqu'il contient toutes les informations nécessaires pour se connecter au vpn (notamment clé privé)**.

Pour créer un utilisateur :

```
# ./create-vpn-user.sh username
```

Après exécution du script, un fichier `username.ovpn` est créé (dans `/etc/openvpn/private-client-conf`) : il peut être diffusé (par un canal sûr !) à l'utilisateur pour configuration de son client.

#### Révoquer un utilisateur
On utilise un script fait maison : [revoke-vpn-user.sh](./revoke-vpn-user.sh)

Il révoque le certificat de l'utilisateur qui ne pourra donc plus se connecter au vpn.
```
# ./revoke-vpn-user.sh username
```

## Administration
Pour lancer manuellement le serveur (après un arrêt manuel par exemple), on relance tout simplement l'interface *tun0* :
```
# sh /etc/netstart tun0
```

Pour vérifier que l'interface *tun0* fonctionne :
```
# ifconfig tun0
```

Pour vérifier le processus :
```
# pgrep -fl openvpn.*server
```

Pour vérifier que le processus écoute sur le bon port :
```
# netstat -an|grep '\.1194 '
```

Pour vérifier les logs :
```
# tail /var/log/openvpn/*
```

Pour arrêter le processus :
```
# pkill -x openvpn
```

Pour accéder à l'interface de management via *telnet* sur le port 1195 depuis le serveur vpn lui-même (s'y connecter en ssh si nécessaire) :
```
# telnet localhost 1195
```
Pour rappel, le mot de passe est stocké en clair dans le fichier `/etc/openvpn/private/mgmt.pwd`.

Une fois connecté, entrer `help` pour obtenir de l'aide.

## Scripts
Les scripts mentionnés plus haut sont accessibles ici :
* Créer la pki : [create-new-pki.sh](./create-new-pki.sh)
* Ajouter un utilisateur : [create-vpn-user.sh](./create-vpn-user.sh)
* Révoquer un utilisateur : [revoke-vpn-user.sh](./revoke-vpn-user.sh)

## Sources
* http://openbsdsupport.org/openvpn-on-openbsd.html
* https://openvpn.net/index.php/open-source/documentation/howto.html
* https://yeuxdelibad.net/ah/#toc153
