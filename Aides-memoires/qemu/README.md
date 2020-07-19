qemu
====

## Quelques combinaisons de touches

Pour accéder au *monitor* de qemu : `[CTRL]+a` puis `c`
Pour rebasculer dans la vm : `[CTRL]+a` puis `c` puis `[ENTER]`
Pour quitter qemu : `[CTRL]+a` puis `x` (ou `q` depuis le *monitor*)

## Image disque

Pour créer une image disque (taille maximale de 20 Go) :
```
$ qemu-img create -f qcow2 disk.qcow2 20G
```

## Snapshots

Pour créer un snapshot :
```
$ qemu-img create -f qcow2 -b original.qcow2 snapshot.qcow2
```

> A partir de ce moment-là, il ne faut plus modifier `original.qcow2` (au risque de corrompre les snapshots créés). Qemu doit donc être lancé avec `snapshot.qcow2`. Pour revenir en arrière, on supprime `snapshot.qcow2` et on recrée un snapshot depuis `original.qcow2` (qui n'a jamais été modifié entre temps).

Pour obtenir des informations sur un snapshot :
```
$ qemu-img info snapshot.qcow2
```

On peut aussi créer un snapshot temporaire en ajoutant le flag `-snapshot` à la ligne de commande de Qemu. Dans ce cas, les modifications sur l'image ne sont pas enregistrées et seront perdues à l'arrêt de la machine virtuelle.

## Démarrage d'une machine virtuelle

Le script [qemu-start.sh](./qemu-start.sh) permet de lancer une machine virtuelle avec qemu.

## Sources

- <https://wiki.qemu.org/Documentation>

