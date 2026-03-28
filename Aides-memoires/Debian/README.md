# Debian

## Divers

En cas de problème, on peut trouver des informations utiles sur un processus
en tapant la commande :
```
sudo journalctl -b _PID=<pid>
```

Changer la disposition du clavier sous un environnement X11 :
```
sudo setxkbmap fr
```

## Mises à jour majeures

### Commandes

En root :

```
apt update
apt upgrade --without-new-pkgs
apt full-upgrade
reboot
apt autoremove --purge
apt purge '~o'
apt autoclean
```

Pour mettre à jour le format des fichiers sources : `sudo apt modernize-sources`

### Fichiers sources.list

#### Buster (10)

```
deb http://archive.debian.org/debian buster main non-free contrib
deb http://archive.debian.org/debian-security buster/updates main contrib non-free
```

#### Bullseye (11)

```
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
```

#### Bookworm (12)

```
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
```

#### Trixie (13)

```
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
```

## Tips ufw

```
ufw allow from 10.0.0.46 proto tcp to any port 3308
ufw delete allow from 10.0.0.46 proto tcp to any port 3308
```

## Rekey SSH server

```
rm /etc/ssh/ssh_host_*
ssh-keygen -A
```

## chroot

```
mount /dev/sda3 /mnt
mount /dev/sda1 /mnt/boot
mount --bind /dev/ /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /sys/ /mnt/sys
mount --bind /run /mnt/run
mount -t proc /proc /mnt/proc
chroot /mnt
mount -a
```