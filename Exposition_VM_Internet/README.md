Exposition d'une VM directement sur Internet
============================================

Cet article explique comment exposer une VM hébergée sur un serveur dédié
directement sur Internet.

Mon cas d'usage est l'exposition directe sur Internet d'une VM *kali*, ce qui
peut parfois être pratique.

Il est donc nécessaire de posséder un serveur dédié (chez *SoYouStart* dans
mon cas). De plus, mon infrastructure est installée sur *Proxmox VE*, ce qui
me permet de créer des VM au besoin.

Le bridge *internet* configuré sur le Proxmox dispose d'une IP fournie par
DHCP par SoYouStart. Cette IP est l'IP principale de notre serveur dédié.

L'idée ici est de créer une IP Failover qu'on va utiliser pour router le
trafic directement à une des VM de l'infrastructure (une *kali* en
l'occurrence).

Pour clarifier :

- **SERVER_IP** : L'adresse IP principale du serveur dédié.
- **FAILOVER_IP** : L'adresse IP failover créée (ne pas confondre avec
  l'adresse IP principale juste au-dessus).
- **GATEWAY_IP** : L’adresse de la passerelle par défaut. Chez SoYouStart,
  il s'agit de l'adresse IP principale (SERVER_IP) dont le dernier octet est
  remplacé par 254.

## Configuration SoYouStart

### Création de l'adresse IP Failover

Dans l'interface de gestion SoYouStart : *IP/Gérer les IPs* puis ajouter une
IP Failover.

Cela va prendre quelques minutes. On reçoit un mail avec l'IP attribuée. Elle
est également affichée dans l'interface SoYouStart. Il s'agit de la
**FAILOVER_IP**.

### Création de l'adresse MAC virtuelle

Le plus simple est de créer une adresse MAC virtuelle associée à cette nouvelle
adresse IP.
On clique sur la roue crantée puis "Ajouter une adresse MAC virtuelle". On
donne un nom à la VM qui sera dernière cette adresse MAC puis on choisit le
type de VM *ovh*. On valide.

Au bout de quelques secondes, l'adresse MAC créée apparaît dans l'interface.

## Configuration Proxmox

On part du principe que la machine virtuelle qui sera joignable à l'adresse
IP Failover est déjà créée.

Il faut alors configurer l'interface réseau virtuelle de cette VM comme ça
(VM à l'arrêt) :

- Bridge : vmbr0 (on veut que notre VM soit directement accessible depuis
  Internet).
- Model : VirtIO (paravirtualized)
- MAC address : l'adresse MAC virtuelle créée juste avant dans l'interface
  SoYouStart.

On valide et on démarre la VM.

## Configuration VM

### Interface réseau

Il faut maintenant configurer l'interface réseau à l'intérieur de la VM.
Dans notre cas, c'est une *kali* (à base de Debian donc). On suppose ici que
l'interface réseau dans la VM se nomme *eth0*.

Pour cela, on ajoute cette section au fichier `/etc/network/interfaces` :
```
auto eth0
iface eth0 inet static
    address FAILOVER_IP
    netmask 255.255.255.255
    broadcast FAILOVER_IP
    post-up ip route add GATEWAY_IP dev eth0
    post-up ip route add default via GATEWAY_IP
    pre-down ip route del GATEWAY_IP dev eth0
    pre-down ip route del default via GATEWAY_IP
```

> Evidement, FAILOVER_IP et GATEWAY_IP sont à remplacer par les bonnes
  valeurs !

On sauve et on redémarre la VM.

### Résolveur DNS

Il est également nécessaire de configurer le résolveur DNS de la VM. Cela
peut se faire très classiquement via le fichier `/etc/resolv.conf`. On peut
utiliser le même serveur DNS que celui fourni par le DHCP de
SoYouStart à notre serveur dédié (voir donc les serveurs DNS sur le Proxmox).

## Sources

- <https://docs.ovh.com/fr/dedicated/network-bridging/>
