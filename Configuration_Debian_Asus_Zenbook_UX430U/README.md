Configuration Debian sur laptop Asus Zenbook UX430U
===================================================

Cette page décrit diverses tâches de configuration et d'optimisation de Debian 10 (Buster) sur un Asus Zenbook UX430U.
A noter que l'installation s'est faite dans un container *LVM* chiffré avec *LUKS*.

Voici les sorties des commandes `lspci` et `lsusb` :
```
$ lspci
00:00.0 Host bridge: Intel Corporation Device 5914 (rev 08)
00:02.0 VGA compatible controller: Intel Corporation Device 5917 (rev 07)
00:04.0 Signal processing controller: Intel Corporation Skylake Processor Thermal Subsystem (rev 08)
00:14.0 USB controller: Intel Corporation Sunrise Point-LP USB 3.0 xHCI Controller (rev 21)
00:14.2 Signal processing controller: Intel Corporation Sunrise Point-LP Thermal subsystem (rev 21)
00:15.0 Signal processing controller: Intel Corporation Sunrise Point-LP Serial IO I2C Controller #0 (rev 21)
00:15.1 Signal processing controller: Intel Corporation Sunrise Point-LP Serial IO I2C Controller #1 (rev 21)
00:15.2 Signal processing controller: Intel Corporation Sunrise Point-LP Serial IO I2C Controller #2 (rev 21)
00:16.0 Communication controller: Intel Corporation Sunrise Point-LP CSME HECI #1 (rev 21)
00:17.0 SATA controller: Intel Corporation Sunrise Point-LP SATA Controller [AHCI mode] (rev 21)
00:1c.0 PCI bridge: Intel Corporation Device 9d10 (rev f1)
00:1c.5 PCI bridge: Intel Corporation Sunrise Point-LP PCI Express Root Port #6 (rev f1)
00:1f.0 ISA bridge: Intel Corporation Device 9d4e (rev 21)
00:1f.2 Memory controller: Intel Corporation Sunrise Point-LP PMC (rev 21)
00:1f.3 Audio device: Intel Corporation Device 9d71 (rev 21)
00:1f.4 SMBus: Intel Corporation Sunrise Point-LP SMBus (rev 21)
01:00.0 3D controller: NVIDIA Corporation Device 1d10 (rev a1)
02:00.0 Network controller: Intel Corporation Device 24fd (rev 78)

$ lsusb
Bus 002 Device 002: ID 0bda:8153 Realtek Semiconductor Corp.
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 004: ID 04f3:0903 Elan Microelectronics Corp.
Bus 001 Device 003: ID 8087:0a2b Intel Corp.
Bus 001 Device 002: ID 13d3:5694 IMC Networks
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

## Le processeur
Vérifier que le kernel intègre bien les éléments pour la configuration du microcode :
```
# grep -i 'microcode' /boot/config-X.XX.XX
```

Si la sortie ressemble à ça :
```
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
```

on peut installer le paquet `intel-microcode` et `iucode-tool` (qui est un outil de gestion du microcode) :
```
# apt install iucode-tool intel-microcode
```

## Les dépôts
Éditer le fichier `/etc/apt/sources.list` et ajouter `contrib non-free` après le `main` dans le premier dépôt (le dépôt `non-free` est malheureusement nécessaire pour l'installation du module wifi).

## Le wifi
Installer le paquet firmware-iwlwifi (non libre) :
```
# apt install firmware-iwlwifi
```

Ajouter le contenu suivant au fichier `/etc/NetworkManager/NetworkManager.conf` (en cas de problème de connexion) :
```
[device]
wifi.scan-rand-mac-address=no
```

## Le trackpad
Installer et compiler `libinput-gestures` depuis le dépôt *Github* : https://github.com/bulletmark/libinput-gestures

Suivre les indications et récupérer le fichier de configuration de l'ancienne machine dans `~/.config/libinput-gestures.conf`.

## Le firewall
La configuration du firewall se fait à l'aide d'un script `iptables` appelé au démarrage par le script `/etc/rc.local`. Pour faire ça :
* Créer les fichiers `/etc/rc.local` et `/etc/firewall.sh` et les rendre exécutable :
```
# touch /etc/rc.local && chmod 700 /etc/rc.local
# touch /etc/firewall.sh && chmod 700 /etc/firewall.sh
```
* Pour lancer le script du firewall au démarrage, ajouter ça à [`/etc/rc.local`](./rc.local) :

* Ajouter le contenu suivant au fichier [`/etc/firewall.sh`](./firewall.sh)

* Rebooter pour tester que les règles se chargent bien.

## Le disque SSD
Quelques manipulations sont à faire pour une meilleure gestion (et une meilleure longévité) du disque SSD. La particularité ici est qu'on utilise *LVM* et *LUKS*.

### Support TRIM dans dm-crypt
Il faut d'abord activer le support *TRIM* au niveau de *dm-crypt*. Pour ça, on ajoute l'option *discard* dans le fichier `/etc/crypttab`. Par exemple :
```
# <target name>    <source device>    <key file>       <options>
sda2_crypt         /dev/sda2          none             luks,discard
```
Note : L'utilisation de cette option peut révéler les secteurs non utilisés du disque, ce qui peut constituer un problème de sécurité.

### Support TRIM dans LVM
On passe à 1 l'option *issue_discards* dans le fichier `/etc/lvm/lvm.conf`. Exemple :
```
# [...]
devices {
   # [...]
   issue_discards = 1
   # [...]
}
# [...]
```

### Support TRIM du système de fichiers
Exécuter le script suivant environ une fois par semaine (utiliser `anacrontab`) :
```
#!/bin/sh
#
# To find which FS support trim, we check that DISC-MAX (discard max bytes)
# is great than zero. Check discard_max_bytes documentation at
# https://www.kernel.org/doc/Documentation/block/queue-sysfs.txt
#
for fs in $(lsblk -o MOUNTPOINT,DISC-MAX,FSTYPE | grep -E '^/.* [1-9]+.* ' | awk '{print $1}'); do
	fstrim "$fs"
done
```

### Post-installation
Après avoir modifier les options de *dm-crypt* et *LVM*, il est nécessaire de régénérer les *initramfs* :
```
# update-initramfs -u -k all
```

Sources :
* https://wiki.debian.org/SSDOptimization
* http://blog.neutrino.es/2013/howto-properly-activate-trim-for-your-ssd-on-linux-fstrim-lvm-and-dmcrypt/

## Le générateur d'entropie
Pour avoir une meilleure entropie, on installe le paquet `rng-tools` et on fait un peu de configuration :
* Installer le paquet :
```
# apt install rng-tools
```
* On vérifie que le noyau intègre tpm :
```
# cat /boot/config-X.XX.XX | grep CONFIG_HW_RANDOM_TPM
```
Si on obtient `y`, c'est bon. Si on a `m`, il faut activer le module `tpm-rng` au boot :
```
# echo tpm-rng >> /etc/modules
# modprobe tpm-rng
```
Si on a ni `y` ni `m`, il faut recompiler le noyau.

* On édite le fichier `/etc/default/rng-tools` pour utiliser `/dev/hwrng` comme source d'entropie :
```
HRNGDEVICE=/dev/hwrng
RNGDOPTIONS="--hrng=intelfwh --fill-watermark=90% --feed-interval=1"
```
* On relance `rng-tools` :
```
# systemctl restart rng-tools
```

Source : https://cryptotronix.com/2014/08/28/tpm-rng/

## Les cartes graphiques
L'ordinateur dispose de deux cartes graphiques : une intégrée au CPU Intel et un GPU NVidia GeForce MX150.
* Il faut installer l'outil *Bumblebee* pour gérer ces deux cartes et optimiser la consommation d'énergie. En effet, on utilisera par défaut le chip Intel et à la demande le GPU NVidia.
* On installe également les pilotes propriétaires NVidia (le driver libre *nouveau* semble ne pas fonctionner avec ce GPU).
* Ne pas oublier d'installer le paquet *virtualgl* (au jour de la rédaction de cet article, les dépôts officiels *Debian* n'intègrent pas ce paquet ; à installer manuellement donc).

Pour lancer une application sur le GPU NVidia, il faut ajouter `optirun` dans la ligne de commande :
```
$ optirun glxgears
```

Pour ouvrir le panneau NVidia :
```
$ optirun nvidia-settings -c :8
```

Sources :
* https://debian-facile.org/doc:materiel:cartes-graphique:nvidia:optimus
* https://wiki.debian.org/Bumblebee

## Gestion d'énergie
Par défaut, il n'y a pas vraiment de gestion (économie) d'énergie, en particulier en mode *suspend* (quand l'écran est fermé par exemple).
Pour améliorer ça, on peut installer *tlp* qui est présent dans les dépôts officiels :
```
# apt install tlp
```

La configuration par défaut est satisfaisante. On reboote ou on lancer le service manuellement.
A noter qu'il y a deux services :
- `tlp.service` : le service lorsque l'ordinateur est allumé
- `tlp-sleep.service` : le service actif lorsque l'ordinateur est en mode *suspend*.

## Le bluetooth
Pour une installation sous *KDE Plasma*
On installe les paquets suivants :
```
# apt install bluetooth bluedevil pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware
```

On relance le service `bluetooth`.

Pour les périphériques de son (casques, écouteurs, ...), il est possible qu'il faille exécuter la commande suivante (si on a une erreur `a2dp-sink profile connect failed for ...` au niveau du service `bluetooth` pendant l’appairage) :
```
# killall pulseaudio
```

Sources :
* https://wiki.debian.org/fr/BluetoothUser
* https://wiki.debian.org/BluetoothUser/a2dp
