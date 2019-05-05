Configuration multiboot dans container LVM chiffré (LUKS)
=========================================================

Ce wiki décrit ma procédure d'installation d'un système multiboot (Debian / Arch Linux / ... dans mon cas) sur un disque dur dont un volume LVM est chiffré avec LUKS.

Ma machine utilise *UEFI*.

Attention, selon les configurations et les systèmes que vous voulez installer, il peut y avoir des différences. Merci donc de ne pas suivre "bêtement" ce tuto et de bien comprendre ce que vous faites... une fausse manipulation peut entraîner une perte de données ou d'accès au système.

## Partitionnement du disque dur
Cette opération peut être faite lors de l'installation du premier système.

**ATTENTION : A partir de maintenant, toutes les données contenues sur le disque dur seront définitivement perdues !!! Faire les sauvegardes nécessaires MAINTENANT !**.

Je suppose dans ce wiki que le disque d'installation est *sda* et qu'il utilise une table de partition *gpt*.

Il va falloir créer les partitions suivantes :
* `sda1` : EFI System Partition / Environ 100 Mo / fat16 (avec les flags *boot* et *esp*)
* `sda2` : Partition de boot du premier OS (ici *Debian*) / Environ 500 Mo / ext2
* `sda3` : Partition de boot du deuxième OS (ici *Arch Linux*) / Environ 500 Mo / ext2
* `sda4` : Partition de boot du troisième OS (laisser libre pour le moment) / Environ 500 Mo / ext2
* `sda5` : Groupe de volumes LVM chiffré avec LUKS (3 volumes *root* pour les systèmes, un ou plusieurs volumes *home* pour les data et une partition *swap* / Le reste du disque

## Installation du premier OS
J'ai installé ma fidèle *Debian* en premier. L'installation est classique mais il faut faire la configuration des volumes LVM et de LUKS lors de l'étape de partitionnement du disque dur.

Un autre point particulier : l'installation de *GRUB* peut se faire sur la partition de boot (qui est ici `/dev/sda2` pour la *Debian*).

Lors de l'installation du premier OS, les étapes suivantes sont automatiques et n'ont pas besoin d'être faites à la main :
* Modification du fichier `/etc/crypttab`
* Modification du fichier `/etc/fstab`
* Configuration de *GRUB*

Après avoir booter le nouvel OS, on peut ajuster quelques paramètres :

Dans le fichier `/etc/default/grub`, ajouter la ligne suivante pour éviter que *GRUB* n'aille chercher des systèmes ailleurs que dans sa propre partition de boot. En effet, c'est le boot manager (*reFind*) qui va gérer ça :
```
GRUB_DISABLE_OS_PROBER=true
```

On régénère les images du noyau (le fait d'avoir fait des partitions boot séparées permet de n'affecter que les images de la partition boot montée) :
```
# update-initramfs -u -k all
```

On met à jour *GRUB* sur la bonne partition de boot :
```
# update-grub /dev/sda2
```

On peut maintenant installer le boot manager !

## Installation d'un boot manager
On utilisera *reFind* comme boot manager. C'est *reFind* qui prend la main au boot et qui renvoie vers les bootloaders spécifiques de chaque OS (par exemple un *GRUB* installé sur la partition de boot spécifique au système choisi).

Il faut donc installer *reFind* : https://www.rodsbooks.com/refind/

On l'installe depuis le premier OS fraîchement installé. Ce choix permet de garder une bonne indépendance entre les OS (et leur partitions de boot : pas de *chaining* entre bootloaders). Et puis, il est pratique pour booter sur des systèmes live ou lancer l'UEFI si on a oublié la touche à taper. Bref... j'aime bien *reFind* ;)

On remarque que l'installation (avec le script `refind-install.sh` va créer un fichier `/boot/refind-linux.conf`. Ce fichier fait le lien entre *reFind* et le bootloader des différents OS. Il permet aussi de passer des arguments au kernel.

## Installation des OS suivants
On lance la procédure d'installation normalement. **Avant de faire le partitionnement du disque, il faut exécuter un shell et monter les volumes chiffrés** pour pouvoir utiliser ceux dont on aura besoin :
```
# cryptsetup luksOpen /dev/sda5 chif
```

On active les volumes LVM pour le groupe entier :
```
# lvchange -ay nomDuGroupeDeVolumes
```

On vérifie qu'ils ont bien été trouvés :
```
# lvscan
```

On peut sortir du shell et poursuivre l'installation classique de l'OS avec le partitionnement du disque dur. Utiliser les partitions prévues pour la racine, le *home*, la *swap* et la (bonne !) partition de *boot* ;)

**Attention à ne pas formater une partition par erreur ou à se tromper de partition...**.

On termine l'installation normalement en installant le bootloader (*GRUB*) mais **surtout sans rebooter !** Le système ne démarrerait pas (il ne saurait pas déchiffrer la partition racine pour booter).

Il faut ouvrir à nouveau un shell avant de rebooter.

On doit se chrooter dans le système qui vient d'être installé pour permettre de booter sur la nouvelle partition root chiffrée. On suppose ici qu'on monte le nouveau système dans `/mnt` :
```
# mount /dev/mapper/[vg-name]-[root2ou3-lv-name] /mnt
# mount -o bind /proc /mnt/proc
# mount -o bind /dev /mnt/dev
# mount -o bind /dev/pts /mnt/dev/pts
# mount -o bind /sys /mnt/sys
# cd /mnt
# chroot /mnt
```

On monte la bonne partition de boot :
```
# mount /dev/sda3ou4 /boot
```

On créé un fichier `/boot/refind-linux.conf` (sur le modèle de celui du premier OS installé ou voir sur le net selon le système installé). Cela permettra à *reFind* de trouver la partition root du système à booter.

On ajoute la ligne suivante au fichier `/etc/crypttab` pour indiquer le volume chiffré (on peut utiliser *blkid* pour trouver l'UUID) :
```
sda5_crypt UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX none luks,discard
```

On vérifie le fichier `/etc/fstab`. Normalement il est ok.

On ajoute la ligne suivante au fichier `/etc/default/grub` (voir plus haut pour voir à quoi ça sert) :
```
GRUB_DISABLE_OS_PROBER=true
```

On régénère les images du noyau :
```
# update-initramfs -u -k all
```

On met à jour *GRUB* sur la bonne partition de boot :
```
# update-grub /dev/sda3ou4
```

On note que *cryptsetup* doit être installé sur le nouveau système.

Normalement, on peut maintenant rebooter. On devrait arriver sur l'écran de *reFind* et pouvoir booter les différents OS installés. Il restera à configurer un peu *reFind* pour avoir un menu un peu plus propre.

## Sources
* https://www.oxygenimpaired.com/multiple-linux-distro-installs-on-a-luks-encrypted-harddrive
* https://medium.com/@teejeetech/linux-multiboot-with-btrfs-luks-and-efi-part-1-9b2325494e0f
