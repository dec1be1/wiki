Sauvegarde et restauration de partitions avec GParted Live
==========================================================

Cet article décrit la procédure à suivre pour sauvegarder et restaurer des partitions entières en utilisant la distribution GNU/Linux [*GParted Live*](https://gparted.org/livecd.php).

La première étape est de booter l'ordinateur sous *GParted Live*. Il faut donc avoir créer une clé usb bootable. Pour certains ordinateurs (les *mac* par exemple), il est nécessaire de booter en mode *UEFI*. Voir *Aide-mémoire UEFI* pour plus d'informations à ce sujet.

A noter qu'il sera nécessaire d'utiliser un support de stockage externe (une autre clé usb, un disque dur externe, ...) pour stocker les images compressées des partitions (ou pour restaurer des images compressées). **Ce support externe devra être formaté en ext3** pour être utilisé sans soucis sous *GParted Live*.

Enfin, pour éviter de chercher certains caractères spéciaux sur un clavier de *macbook* :
* le *pipe* (|) : Atl(right) + 6 ou £
* le signe *égal* (=) : touche *tiret* (située à gauche du *backspace*)
* les signes < et > : & et 1 ou / et .

## Sauvegarde de partitions
* Ouvrir une console et se logger en *root* :
```
$ sudo su
```
* Passer le clavier en français :
```
# setxkbmap fr
```
* Créer un répertoire pour le stockage externe :
```
# mkdir /media/EXTERNE
```
* Monter le stockage externe (en supposant que le périphérique est `/dev/sdc`) :
```
# mount /dev/sdc1 /media/EXTERNE
```

> Note : Si on veut sauvegarder une partition chiffrée, on peut y accéder en l'ouvrant avec `cryptsetup`. Si la partition utilise LVM, on peut lister les volumes avec `lvscan` pour vérifier qu'ils sont bien actifs.

* Lancer la sauvegarde (`dd` est ton ami ;)) :
```
# dd if=/dev/sda8 | gzip -v6 | dd of=/media/EXTERNE/$(date +%Y%m%d)_mac_root_sda8.gz
```
* Créer une somme de contrôle :
```
# sha256sum /media/EXTERNE/$(date +%Y%m%d)_mac_root_sda8.gz > /media/EXTERNE/$(date +%Y%m%d)_mac_root_sda8.gz.sha256
```

## Restauration de partitions
* Comme pour la sauvegarde : booter sous *GParted Live*, ouvrir une console en *root*, créer le répertoire pour le stockage externe (`/media/EXTERNE`) et monter le stockage externe.
* Vérifier la somme de contrôle :
```
# sha256sum /media/EXTERNE/20180729_mac_root_sda8.gz && cat /media/EXTERNE/20180729_mac_root_sda8.gz.sha256
```
* Lancer la restauration :
```
# zcat /media/EXTERNE/20180729_mac_root_sda8.gz | dd of=/dev/sda8
```
