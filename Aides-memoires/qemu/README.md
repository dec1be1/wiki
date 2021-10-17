qemu
====

## Quelques combinaisons de touches

- Pour accéder au *monitor* de qemu : `[CTRL]+a` puis `c`
- Pour rebasculer dans la vm : `[CTRL]+a` puis `c` puis `[ENTER]`
- Pour quitter qemu : `[CTRL]+a` puis `x` (ou `q` depuis le *monitor*)

## Image disque

### Création

Pour créer une image disque (taille maximale de 20 Go) :
```
$ qemu-img create -f qcow2 disk.qcow2 20G
```

### Conversion

Pour convertir une image du format *VirtualBox* (vdi) au format *qemu*
(qcow2) :
```
qemu-img convert -c -f vdi disk.vdi -O qcow2 disk.qcow2
```

Voir le *man* pour la prise en charge d'autres formats.

> Note : Ca peut être très long (plusieurs heures) selon la taille des images
  à traiter.

## Snapshots

Pour créer un snapshot :
```
$ qemu-img create -f qcow2 -b base.qcow2 -F qcow2 snapshot.qcow2
```

> A partir de ce moment-là, il ne faut plus modifier `base.qcow2`
  (au risque de corrompre les snapshots créés). Qemu doit donc être lancé
  avec `snapshot.qcow2`. Pour revenir en arrière, on supprime `snapshot.qcow2`
  et on recrée un snapshot depuis `base.qcow2` (qui n'a jamais été
  modifié entre temps).

Pour appliquer les changements d'un snapshot dans l'image de base :
```
$ qemu-img commit snapshot.qcow2
```

> On peut ensuite supprimer le fichier du snapshot.

Pour obtenir des informations sur un snapshot :
```
$ qemu-img info snapshot.qcow2
```

Pour avoir toute la chaîne d'images :
```
$ qemu-img info --backing-chain snapshot.qcow2
```

On peut aussi créer un snapshot temporaire en ajoutant le flag `-snapshot` à
la ligne de commande de Qemu. Dans ce cas, les modifications sur l'image ne
sont pas enregistrées et seront perdues à l'arrêt de la machine virtuelle.

## Réduction image qcow2

Il faut d'abord mettre des zéros dans les zones non utilisées de l'image.
Pour une machine virtuelle Linux, depuis la VM :
```
# dd status=progress if=/dev/zero of=/mytempfile
# rm -f /mytempfile
```

On éteint ensuite la VM et on peut réduire l'image en faisant une conversion
de qcow2 vers qcow2 :
```
$ qemu-img convert -c -O qcow2 source.qcow2 shrunk.qcow2
```

> Pour éviter d'avoir à faire ça régulièrement, on peut activer *TRIM* dans
  la VM (selon le système d'exploitation). Il faut également que le matériel
  le supporte. C'est le cas des dernières versions de *Virtio*. Il faut
  ajouter l'option `discard=unmap` au disque dur de la VM.

## Monter une image disque qcow2

Il faut :

1. Démarrer le module `nbd` (*network block device*)
2. Connecter le fichier à un *network block device*
3. Lister les partitions
4. Monter la partition

Dans l'ordre :
```
# modprobe nbd max_part=8
# qemu-nbd --connect=/dev/nbd0 disk.qcow2
# fdisk /dev/nbd0 -l
# mount /dev/nbd0p1 /mnt/somepoint/
```

Lorsqu'on a fini :
```
# umount /mnt/somepoint/
# qemu-nbd --disconnect /dev/nbd0
# rmmod nbd
```

## Machine virtuelle en mode texte

Si on n'a pas besoin d'un affichage graphique pour sa machine virtuelle, le
plus simple est d'utiliser l'option `-nographic` de la ligne de commande
*qemu* qui va rediriger le port série du guest vers le stdio de l'host
(équivalent à `-serial stdio`).

Dans ce cas, il faut, dans le guest, rediriger l'affichage vers le port série.
Par exemple, sous *debian* avec *grub* :

1. Editer `/etc/default/grub` pour ajouter les lignes suivantes :
```
GRUB_CMDLINE_LINUX='console=tty0 console=ttyS0,115200n8'
GRUB_TERMINAL=serial
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
```
2. Mettre à jour *grub* : `# update-grub`.
3. Redémarrer

## Démarrage d'une machine virtuelle

Ce [Makefile](./Makefile) permet de configurer et de lancer facilement une
machine virtuelle.

## Sources

- <https://wiki.qemu.org/Documentation>
- <https://wiki.archlinux.org/index.php/QEMU>
- <https://doc.ycharbi.fr/index.php/Qemu>
- <https://www.spice-space.org/spice-user-manual.html>
- <https://blog.programster.org/qemu-img-cheatsheet>
