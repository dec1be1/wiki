Configuration Debian sur MacBookPro 8.1 (Early 2011)
====================================================

Cette page décrit diverses tâches de configuration et d'optimisation de Debian 9 (Stretch) sur un MacBookPro 8.1 (Early 2011).

Le processeur est un Intel(R) Core(TM) i5-2415M CPU @ 2.30GHz (2 cœurs / Sandy Bridge).

Pour le reste du matériel, voici les sorties des commandes `lspci` et `lsusb` :
```
$ lspci
00:00.0 Host bridge: Intel Corporation 2nd Generation Core Processor Family DRAM Controller (rev 09)
00:01.0 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09)
00:01.1 PCI bridge: Intel Corporation Xeon E3-1200/2nd Generation Core Processor Family PCI Express Root Port (rev 09)
00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09)
00:16.0 Communication controller: Intel Corporation 6 Series/C200 Series Chipset Family MEI Controller #1 (rev 04)
00:1a.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Universal Host Controller #5 (rev 05)
00:1a.7 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #2 (rev 05)
00:1b.0 Audio device: Intel Corporation 6 Series/C200 Series Chipset Family High Definition Audio Controller (rev 05)
00:1c.0 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 1 (rev b5)
00:1c.1 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 2 (rev b5)
00:1c.2 PCI bridge: Intel Corporation 6 Series/C200 Series Chipset Family PCI Express Root Port 3 (rev b5)
00:1d.0 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Universal Host Controller #1 (rev 05)
00:1d.7 USB controller: Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller #1 (rev 05)
00:1f.0 ISA bridge: Intel Corporation HM65 Express Chipset Family LPC Controller (rev 05)
00:1f.2 SATA controller: Intel Corporation 6 Series/C200 Series Chipset Family 6 port SATA AHCI Controller (rev 05)
00:1f.3 SMBus: Intel Corporation 6 Series/C200 Series Chipset Family SMBus Controller (rev 05)
02:00.0 Ethernet controller: Broadcom Limited NetXtreme BCM57765 Gigabit Ethernet PCIe (rev 10)
02:00.1 SD Host controller: Broadcom Limited BCM57765/57785 SDXC/MMC Card Reader (rev 10)
03:00.0 Network controller: Broadcom Limited BCM4331 802.11a/b/g/n (rev 02)
04:00.0 FireWire (IEEE 1394): LSI Corporation FW643 [TrueFire] PCIe 1394b Controller (rev 08)
05:00.0 PCI bridge: Intel Corporation CV82524 Thunderbolt Controller [Light Ridge 4C 2010]
06:00.0 PCI bridge: Intel Corporation CV82524 Thunderbolt Controller [Light Ridge 4C 2010]
06:03.0 PCI bridge: Intel Corporation CV82524 Thunderbolt Controller [Light Ridge 4C 2010]
06:04.0 PCI bridge: Intel Corporation CV82524 Thunderbolt Controller [Light Ridge 4C 2010]
06:05.0 PCI bridge: Intel Corporation CV82524 Thunderbolt Controller [Light Ridge 4C 2010]
06:06.0 PCI bridge: Intel Corporation CV82524 Thunderbolt Controller [Light Ridge 4C 2010]
07:00.0 System peripheral: Intel Corporation CV82524 Thunderbolt Controller [Light Ridge 4C 2010]

$ lsusb
Bus 002 Device 003: ID 05ac:8242 Apple, Inc. Built-in IR Receiver
Bus 002 Device 002: ID 0424:2513 Standard Microsystems Corp. 2.0 Hub
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 001 Device 003: ID 05ac:8509 Apple, Inc. FaceTime HD Camera
Bus 001 Device 005: ID 05ac:0245 Apple, Inc. Internal Keyboard/Trackpad (ANSI)
Bus 001 Device 008: ID 05ac:821a Apple, Inc. Bluetooth Host Controller
Bus 001 Device 004: ID 0a5c:4500 Broadcom Corp. BCM2046B1 USB 2.0 Hub (part of BCM2046 Bluetooth)
Bus 001 Device 002: ID 0424:2513 Standard Microsystems Corp. 2.0 Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
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

on peut installer le paquet *intel-microcode* et *iucode-tool* (qui est un outil de gestion du microcode) :
```
# apt install iucode-tool intel-microcode
```

## Le clavier
### Configuration générale
Installer les paquets suivants :
```
# apt install keyboard-configuration console-setup
```

Pour que le clavier soit correctement mappé, mettre le contenu suivant dans le fichier `/etc/default/keyboard` :
```
XKBMODEL=pc105
XKBLAYOUT=fr
XKBVARIANT=mac
XKBOPTIONS=lv3:switch,compose:lwin
BACKSPACE=guess
```

### Touches inversées
Il est possible qu'après la configuration générale les touches `<>` et `@#` soient inversées. Dans ce cas, il faut exécuter une commande au démarrage pour rétablir la situation. Pour automatiser ça au démarrage, on peut :
* Créer un lanceur dans `~/.config/autostart/kb_inverse.desktop` et y coller le contenu suivant :
```
[Desktop Entry]
Type=Application
Name=kb_inverse
Exec=/home/USER/bin/kb_reverse_at_lt.sh
Terminal=false
```
* Créer le script [`/home/USER/bin/kb_reverse_at_lt.sh`](./kb_reverse_at_lt.sh).

## Les dépôts
Éditer le fichier `/etc/apt/sources.list` et ajouter `contrib non-free` après le *main* dans le premier dépôt (le dépôt *non-free* est malheureusement nécessaire pour l'installation du module wifi.

## Le wifi
Installer le paquet *firmware-b43-installer* (non libre) :
```
# apt install firmware-b43-installer
```

## La carte graphique Intel
Si le driver Intel (*i915*) n'est pas installé (dans le noyau ou en module), il faut l'ajouter au noyau et le recompiler (dans le noyau ou en module). Le noyau doit être au moins en version 4.8. Ensuite, on peut supprimer certains paquets inutiles :
```
# apt purge xserver-xorg-video-intel xserver-xorg-video-all xserver-xorg-video-amdgpu xserver-xorg-video-ati xserver-xorg-video-radeon
```
On peut rebooter.

## Le trackpad
A venir... ou pas.

## Le firewall
Cf. wiki *Configuration Debian sur Asus Zenbook UX430U*.

## Le disque SSD
Si le disque est de type SSD, il faut activer le *trim*. Pour ça, on ajoute une tâche journalière dans le fichier `/etc/anacrontab` qui lance le script suivant [dofstrim.sh](./dofstrim.sh).

## Le bluetooth
* Pour désactiver le bluetooth au démarrage : ajouter la ligne suivante au fichier `/etc/rc.local` :
```
# echo "rfkill block bluetooth" >> /etc/rc.local
```
* On édite le fichier `/etc/systemd/system/bluetooth.target.wants/bluetooth.service` et on ajoute ` --noplugin=sap` à la fin de la ligne `ExecStart=/usr/lib/bluetooth/bluetoothd`.
* On lance le module *btusb* au démarrage :
```
# echo btusb >> /etc/modules
```
* On installer les paquets suivants :
```
# apt install pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware
```
* On crée le fichier `/etc/modprobe.d/b43.conf` et on le complète :
```
# echo "options b43 btcoex=0" > /etc/modprobe.d/b43.conf
```
* On ajoute la ligne suivante au fichier `/etc/pulse/default.pa` :
```
echo "load-module module-switch-on-connect" >> /etc/pulse/default.pa
```
* On reboote pour tester tout ça.

## Les partitions
* Dans `/etc/fstab`, ajouter l'option *noatime* aux partitions *ext4* des disques SSD.
* On peut également désactiver le montage automatique de la partition */boot/efi* (a priori */dev/sda1*). On pourra la monter manuellement si besoin.

## La prise jack (SPDIF)
La prise jack dispose d'un port SPDIF qui émet par défaut une lumière rouge. Pour l'éteindre :
* Lancer `alsamixer` dans une console puis muter le SPDIF.
* Sauver la configuration en tapant :
```
# alsactl store
```

## Le générateur d'entropie
Pour avoir une meilleure entropie, on installe le paquet *rng-tools* et on fait un peu de configuration :
* Installer le paquet :
```
# apt install rng-tools
```
* On vérifie que le noyau intègre tpm :
```
# cat /boot/config-X.XX.XX | grep CONFIG_HW_RANDOM_TPM
```
Si on obtient `y`, c'est bon. Si on a `m`, il faut activer le module *tpm-rng* au boot :
```
# echo tpm-rng >> /etc/modules
# modprobe tpm-rng
```
Si on a ni `y` ni `m`, il faut recompiler le noyau.

* On édite le fichier `/etc/default/rng-tools` pour utiliser `/dev/urandom` comme source (on peut peut-être améliorer selon les processeurs et utiliser `/dev/hwrng` mais je n'ai pas assez cherché... en le configurant sur `/dev/hwrng`, il ne se lance pas au boot mais se lance correctement en relançant le service `rng-tools` après le boot...) :
```
HRNGDEVICE=/dev/urandom
RNGDOPTIONS="--hrng=intelfwh --fill-watermark=90% --feed-interval=1"
```
* On relance rng-tools :
```
# systemctl restart rng-tools
```

Source : https://cryptotronix.com/2014/08/28/tpm-rng/

## Le lecteur de carte SD
Le lecteur de carte SD est de marque Broadcom type BCM57765/57785 :
```
$ lspci | grep SD
02:00.1 SD Host controller: Broadcom Limited BCM57765/57785 SDXC/MMC Card Reader (rev 10)
```

Il ne fonctionne pas bien par défaut (pas pour toutes les cartes).

Pour le faire fonctionner (ces commandes sont à faire avec les droits de l'utilisateur *root*) :
* Ajouter la ligne suivante aux fichiers `/etc/rc.local` et `/etc/apm/resume.d/21aspm` (si ce fichier n'existe pas il faut le créer ; mettre les mêmes droits que ses copains) :
```
setpci -s 00:1c.2 0x50.B=0x41
```
* Ajouter la ligne suivante au fichier `/etc/modprobe.d/sdhci.conf` (le créer s'il n'existe pas) :
```
options sdhci debug_quirks2=4
```
* Régénérer l'initrd :
```
# update-initramfs -u -k all
```
* Rebooter pour tester que tout fonctionne.


Source : https://gist.github.com/samgooi4189/2e6e18fd1d562acaf39246e5e386d7cb

## Le ventilateur
Pour la gestion de la vitesse de rotation du ventilateur :
* Installer le paquet *macfanctld* :
```
# apt install macfanctld
```
* On éditer le fichier de configuration [`/etc/macfanctl.conf`](./macfanctl.conf).

## La gestion de l'énergie
On peut installer et activer *tlp* pour une meilleure gestion de l'énergie :
```
# apt install tlp
# systemctl enable tlp.service
# systemctl enable tlp-sleep.service
# systemctl disable systemd-rfkill.service
```

Source : http://linrunner.de/en/tlp/tlp.html

## ntpdate
* Installer le paquet :
```
# apt install ntpdate
```
* Modifier le fichier de configuration (`/etc/default/ntpdate`) pour y ajouter les serveurs qu'on veut. Typiquement :
```
NTPSERVERS="0.fr.pool.ntp.org 1.fr.pool.ntp.org 2.fr.pool.ntp.org 3.fr.pool.ntp.org"```
* Lancer ntpdate-debian (ntpdate sera ensuite lancé au démarrage d'une interface réseau) :
```
# ntpdate-debian
```
