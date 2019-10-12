dd
==

**Attention avec ''dd'' !!! Toujours vérifier (deux ou trois fois...) la commande avant de valider.**

## Création d'une clé usb bootable
Pour créer une clé usb bootable (par exemple sur `/dev/sdb`) :
* Démonter la clé si elle est montée.
* Lancer la copie :
```
# dd if=fichierImageBootable.iso of=/dev/sdb bs=512k
```

## Création d'une sauvegarde compressée d'une partition entière
Pour sauvegarder une partition (ou un volume LVM `/dev/volumeGroup/volume`) et la compresser :
```
# dd if=/dev/sdb1 | gzip -v6 | dd of=/mnt/SAV/volume_`date +%Y-%m-%d`.gz
```

## Restauration d'une partition à partir d'une sauvegarde compressée
Pour restaurer la partition (il faut que la partition qui reçoit les données soit de la même taille que la partition source) :
```
# zcat /mnt/SAV/volume_20160507.gz | dd of=/dev/sdb1
```

## Connaître l'avancement de la commande dd
La commande *dd* est assez silencieuse. Pour connaître son avancement, on peut lui envoyer un signal `USR1` avec `kill` :
```
# kill -USR1 $(pgrep ^dd$)
```

On peut aussi utiliser `watch` pour lancer la commande périodiquement (toutes les 60 secondes par exemple) :
```
# watch -n60 kill -USR1 $(pgrep ^dd$)
```

## Extraire une séquence d'octets dans un fichier
Extraction de 64 octets à partir du 37ème dans le fichier `source`. Le nouveau fichier est créé et s'appelle `target` :
```
$ dd if=./source of=./target bs=1 skip=37 count=64
```
