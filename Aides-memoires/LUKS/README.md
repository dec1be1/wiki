LUKS (cryptsetup)
=================

Ce wiki constitue mon aide-mémoire pour l'utilisation de LUKS avec cryptsetup
sous Linux.

Pour afficher la liste des volumes sous GNU/Linux :
```
# blkid
```

## Création de volumes chiffrés

### Créer un container vide

Exemple pour un container de 1 Go (rempli avec des données aléatoires) :
```
$ dd if=/dev/urandom of=/home/ju/container bs=1M count=1000
```

### Chiffrer un volume (container ou partition)

Exemple pour le container créé précédemment (avec un chiffrement fort) :
```
# cryptsetup luksFormat -c aes-xts-plain64 -s 512 -h sha512 /home/ju/container
```
Pour chiffrer une partition, remplacer `/home/ju/container` par le nom de la
partition (ex : `/dev/sdc1`).

## Gestion des volumes chiffrés

### Monter le volume

On mappe le disque chiffré sur `/dev/mapper/chif` :
```
# cryptsetup luksOpen /dev/sdc1 chif
```

On monte le volume :
```
# mount /dev/mapper/chif /mnt/VolumeChiffre
```

### Démonter le volume

Pour démonter le volume :
```
# umount /mnt/VolumeChiffre
# cryptsetup luksClose chif
```

### Afficher les informations

Pour afficher les informations sur une partition chiffrée :
```
# cryptsetup luksDump /dev/sdc1
```

### Ajouter une clé d'accès

Pour ajouter une clé d'accès (s'il reste au moins un slot disponible) :
```
# cryptsetup luksAddKey /dev/sdc1
```

### Supprimer une clé d'accès

```
# cryptsetup luksKillSlot /dev/sdc1 <num_slot>
```

## Gestion des headers

Le *header* d'une partition *LUKS* contient notamment les *keyslots*
(8 *keyslots* soit 8 passphrases possibles). Chaque *keyslot* contient une
copie chiffrée (à l'aide d'une passphrase entrée par l'utilisateur) de la
*master key* qui permet le déchiffrement des données de la partition.
Le *header* contient également des informations sur la méthode de chiffrement.

### Exporter un header

Il est possible d'exporter le *header* d'une partition pour le sauvegarder en
lieu sûr (en le chiffrant au passage). Cela est utile notamment lorsqu'un
*keyslot* est occupé par une *nuke key*. Pour exporter le *header* d'une
partition *LUKS* dans un fichier
(**attention, le fichier généré n'est pas chiffré**) :
```
# cryptsetup luksHeaderBackup --header-backup-file luksheader.back /dev/sdc1
```

### Restauration du header

Pour restaurer le *header* d'une partition à partir d'un fichier (ne pas
oublier de déchiffrer le fichier avant...) :
```
# cryptsetup luksHeaderRestore --header-backup-file luksheader.back /dev/sdc1
```

## LUKS Nuke

La fonction *LUKS Nuke* permet de créer une *nuke key* dans un *keyslot* libre
d'une partition *LUKS*. Si cette *nuke key* est entrée au moment du montage de
la partition, tous les *keyslots* sont initialisés et les données deviennent
irrécupérables (à moins que le *header* initial de la partition ait été
sauvegardé ailleurs puis restauré).

Pour ajouter une *nuke key* :
```
# cryptsetup luksAddNuke /dev/sdc1
```

## Ne pas oublier !

Après la création d'un volume chiffré, ne pas oublier de créer le dossier pour
monter le volume :
```
# mkdir /mnt/VolumeChiffre
```

Et de créer le système de fichiers (exemple pour ext4) :
```
# mkfs.ext4 /dev/mapper/chif
```
