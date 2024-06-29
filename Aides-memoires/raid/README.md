# RAID

## RAID 1

Ce mode permet d'avoir de la redondance et donc sécuriser les données en cas de
défaillance d'un des disques. L'inconvénient est qu'on divise la capacité
totale disponible par le nombre de membres dans le cluster.

### Configuration

**/!\\ Les données des disques à mettre dans le cluster seront perdues.**

On va faire ici du RAID *software* sous Linux avec *mdadm*.

Pour préparer le disque `/dev/sdb` à rejoindre un cluster (on peut aussi
utiliser `fdisk`) :
```
sudo parted --script /dev/sdb "mklabel gpt"
sudo parted --script /dev/sdb "mkpart primary 0% 100%"
sudo parted --script /dev/sdb "set 1 raid on"
```

Pour créer un cluster avec les partitions `/dev/sdb1` et `/dev/sdc1`:
```
sudo mdadm --create /dev/md0 --level=raid1 --raid-devices=2 /dev/sdb1 /dev/sdc1
```

> Ca peut être long ! Environ une heure ou deux par TB.

On se retrouve avec un périphérique bloc classique sur `/dev/md0`. Il faut le
formatter puis ajouter l'entrée dans `/etc/fstab`.

Enfin, il faut sauvegarder la configuration puis recréer le initramfs :
```
sudo mdadm --detail --scan > /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

> Cette commande est à taper à chaque modification du cluster
> (ajout/suppression/remplacement disque, ...).

### Informations

Pour voir l'état du raid :
```
sudo cat /proc/mdstat
```

Pour suivre en direct :
```
sudo watch -n 1 cat /proc/mdstat
```

### Dépannage

#### Tentatives

Dans le cas où on reçoit un message de ce type (par mail par exemple) :
`A Fail event had been detected on md device ...`, ça peut être un problème 
matériel. Exemple dans mdstat (ici sdd1 en *fail* sur md0):
```
sudo cat /proc/mdstat

Personalities : [raid1] [raid0] [raid6] [raid5] [raid4] [raid10]
md1 : active raid1 sda1[1] sdb1[0]
      3906884608 blocks super 1.2 [2/2] [UU]
      bitmap: 0/30 pages [0KB], 65536KB chunk

md0 : active raid1 sdd1[1](F) sdc1[0]
      3906884608 blocks super 1.2 [2/1] [U_]
      bitmap: 30/30 pages [120KB], 65536KB chunk

unused devices: <none>
```

On peut cependant tenter de ré-ajouter le disque au cluster RAID :
```
sudo mdadm --re-add /dev/md0 /dev/sdd1
```

Si ça ne marche pas on peut le tenter en 2 fois :
```
sudo mdadm --remove /dev/md0 /dev/sdd1
sudo mdadm --add /dev/md0 /dev/sdd1
```

Si ça ne marche troujours pas, il faut probablement changer le disque.

On peut également faire des tests avec smartmontools :
<https://medium.com/@sandrodz/a-degradedarray-event-had-been-detected-3d19c5257fa6>

#### Remplacement disque

> On parle ici d'un disque de stockage. Si c'est un disque bootable, il faut 
> aussi créer un bootloader... voir les sources pour ça (pas couvert ici).

Avant de remplacer un disque, on le marque en *faulty* si besoin puis on le 
supprime du cluster :
```
sudo mdadm /dev/md0 -f /dev/sdd1
sudo mdadm --remove /dev/md0 /dev/sdd1
```

On peut alors remplacer physiquement le disque.

Il faut alors déterminer le type de table de partition d'un des disques 
restants dans le cluster :
```
sudo gdisk -l /dev/sdc
```

On suppose dans la suite que c'est du *GPT*.

On prépare le nouveau disque à intégrer le cluster (comme pour la phase de configuration):
```
sudo parted --script /dev/sdd "mklabel gpt"
sudo parted --script /dev/sdd "mkpart primary 0% 100%"
sudo parted --script /dev/sdd "set 1 raid on"
```

On a maintenant une partition `sdd1` sur le disque.

On copie la table de partition du disque sain (ici sdc) vers le nouveau 
disque (ici sdd) :
```
sudo sgdisk -R /dev/sdd /dev/sdc
```

On met un UUID aléatoire sur le nouveau disque :
```
sudo sgdisk -G /dev/sdd
```

On peut ajouter le nouveau disque au cluster :
```
sudo mdadm /dev/md0 --add /dev/sdd1
```

La synchronisation commence. On peut la suivre avec `sudo watch -n 1 cat /proc/mdstat`.

Enfin, comme à l'installation, il faut sauvegarder la configuration puis 
recréer le initramfs :
```
sudo mdadm --detail --scan > /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

## Sources

- <https://wiki.debian-fr.xyz/Raid_logiciel_(mdadm)>
- <https://www.server-world.info/en/note?os=Debian_11&p=raid1>
- <https://www.linuxtricks.fr/wiki/print.php?id=446>
- <https://docs.selectel.ru/en/servers-and-infrastructure/dedicated/troubleshooting/replace-disk-raid/>
