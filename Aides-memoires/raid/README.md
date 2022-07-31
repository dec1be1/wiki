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

### Informations

Pour voir l'état du raid :
```
sudo cat /proc/mdstat
```

Pour suivre en direct :
```
sudo watch -n 1 cat /proc/mdstat
```


## Sources

- <https://wiki.debian-fr.xyz/Raid_logiciel_(mdadm)>
- <https://www.server-world.info/en/note?os=Debian_11&p=raid1>
