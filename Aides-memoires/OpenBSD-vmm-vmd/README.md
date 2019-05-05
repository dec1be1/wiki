vmm/vmd (Virtualisation OpenBSD)
================================

Ce wiki est un aide-mémoire pour l'utilisation du daemon de virtualisation d'OpenBSD (vmm/vmd).

## Connexion à une machine virtuelle existante
La connexion peut se faire soit de manière classique par ssh, soit en mode *serial terminal emulator (cu)* :
```
# vmctl console id_de_la_vm
```
Pour quitter `cu` :
```
# ~.
```
Voir le man de `cu` pour plus d'informations.

## Création d'une nouvelle machine virtuelle
Pour créer la machine `newVM` :
* Création d'une image disque de 10G et ajustement des droits :
```
# vmctl create /mnt/data/VMs/disks/newVM.img -s 10G
# chown _vm:wheel /mnt/data/VMs/disks/newVM.img
# chmod 600 /mnt/data/VMs/disks/newVM.img
```
* On démarre la machine virtuelle avec le ramdisk du dom0 (`/bsd.rd`) ; l'interface `uplink_dmz` doit être définie dans le fichier `/etc/vm.conf` :
```
# vmctl start "newVM" -c -b /bsd.rd -m 1G -n "uplink_dmz" -d /mnt/data/VMs/disks/newVM.img
```
Pour booter depuis une image ISO (installation de [Alpine Linux](https://www.alpinelinux.org/ ''Alpine Linux'') par exemple) :
```
# vmctl start "alpine" -c -m 4G -n "uplink_dmz" -r /mnt/data/VMs/disks/alpine-virt-3.7.0-x86_64.iso -d /mnt/data/VMs/disks/alpine.img
```
* Installer *OpenBSD* normalement (installer également les patchs de sécurité avec `syspatch`).
* Après l'installation, créer le fichier de configuration de la nouvelle vm : [`/mnt/data/VMs/conf/newVM.conf`](./newVM.conf)
On note que le `X` de `tapX` doit être un entier non encore utilisé par une autre vm. Si `X` dépasse 3, il faut créer manuellement une nouvelle interface :
```
# cd /dev; sh MAKEDEV tapX
```
De plus, l'adresse mac ne doit pas être prise par une autre vm.
* Ajuster les droits :
```
# chown _vm:wheel /mnt/data/VMs/conf/newVM.conf
# chmod 600 /mnt/data/VMs/conf/newVM.conf
```
* Inclure le fichier de configuration de la vm dans le fichier `/etc/vm.conf` :
```
# echo include \"/mnt/data/VMs/conf/newVM.conf\" >> /etc/vm.conf
```
* Recharger la configuration du daemon *vmd* :
```
# rcctl reload vmd
```

## Mise à jour d'une machine virtuelle

* Mettre d'abord à jour la machine hôte (le dom0). Le nouveau ramdisk doit être à la racine (`/bsd.rd`).
* Faire les étapes *pre-upgrade* sur la vm à mettre à jour : voir [FAQ officielle d'OpenBSD](https://www.openbsd.org/faq/).
* Désactiver, sur le système hôte, la tâche *cron* qui vérifie que les vm tournent bien (`check_vm.sh`).
* Eteindre la vm :
```
# vmctl stop newVM
```
* Commenter la ligne `include` du fichier `/etc/vm.conf` de la vm à mettre à jour.
* Recharger la configuration du daemon *vmd* :
```
# rcctl reload vmd
```
* On démarre la machine virtuelle manuellement avec le ramdisk du dom0 (le nouveau `/bsd.rd`) :
```
# vmctl start "newVM" -c -b /bsd.rd -m 1G -n "uplink_dmz" -d /mnt/data/VMs/disks/newVM.img
```
* Choisir `(U)pgrade` puis suivre les indications à l'écran.
* Redémarrer la vm.
* Eteindre la vm :
```
# vmctl stop newVM
```
* Dé-commenter la ligne `include` du fichier `/etc/vm.conf`.
* Recharger la configuration du daemon *vmd* :
```
# rcctl reload vmd
```
* Démarrer la vm manuellement :
```
# vmctl start newVM -c
```
* Terminer la mise à jour selon les indications de la [FAQ officielle d'OpenBSD](https://www.openbsd.org/faq/).
* Ré-activer, sur le système hôte, la tâche *cron* qui vérifie que les vm tournent bien (`check_vm.sh`).
