Flash du firmware usine sur un routeur TP-Link WR1043ND v2.1
============================================================

Ce wiki décrit la méthode utilisée pour flasher le firmware usine grâce à
la connexion série du routeur en utilisant un serveur *tftp* pour uploader le
nouveau firmware.

On fait tout ça depuis un firmware *openwrt* qui semblait "briqué"
(plus d'accès web ou ssh). La procédure peut être à adapter selon le système
depuis lequel on boote.

## Pré-requis

### Connexion série

Le routeur est équipé d'une connectique série (à souder soi-même !).
Il faut évidemment avoir fait cette étape pour continuer. Il faut également
disposer d'un adaptateur *USB/série* (ou d'un vieux PC avec un port série...).
On note que les pins sur le routeur correspondent à (en partant du côté du
condensateur) :

* VCC (3.3 V)
* Ground
* RX
* TX

Le branchement à l'adaptateur usb/série doit se faire de la manière suivante :

* VCC (3.3 V) <--> non connecté
* Ground <--> Ground
* RX <--> TX
* TX <--> RX

### Emulateur de terminal

Il faut avoir un émulateur de terminal. J'ai utilisé *minicom* sous GNU/Linux.

On branche l'adaptateur USB/série puis on regarde dans `/var/log/messages`
pour avoir le point de montage du périphérique. Chez moi c'était
`/dev/ttyUSB0`.

On démarre minicom :
```
# minicom -D /dev/ttyUSB0
```

La configuration est la suivante :
```                                                  
+-----------------------------------------------------------------------+         
| A -                             Port série : /dev/ttyUSB0             |         
| B - Emplacement du fichier de verrouillage : /var/lock                |         
| C -            Programme d'appel intérieur :                          |         
| D -            Programme d'appel extérieur :                          |         
| E -                      Débit/Parité/Bits : 115200 8N1               |         
| F -              Contrôle de flux matériel : Non                      |         
| G -              Contrôle de flux logiciel : Non                      |                 
+-----------------------------------------------------------------------+
```

### Serveur tftp

Il va nous falloir un serveur *tftp* pour uploader le firmware.
On installe par exemple `tftpd-hpa` sous GNU/Linux.
Il faudra copier le firmware à uploader dans le dossier du serveur.
La configuration se fait dans le fichier suivant : `/etc/default/tftpd-hpa`.

### Configuration réseau

Il faut configurer une interface réseau pour la connexion au serveur *tftp*.
On déconnecte toutes les inferfaces (sauf celle qui va être utilisée) et on
désactive le wifi.

On configure l'interface avec les paramètres suivants :
```
# ip a add 192.168.1.100/24 dev eth0
# ip route add default via 192.168.1.1 dev eth0
```

### Le firmware

On va flasher le firmware usine pour repartir sur de bonnes bases (on
installera ensuite le firmware de notre choix !).

On télécharge la dernière version sur le
[site du fabricant](https://www.tp-link.com/fr/support/download/tl-wr1043nd/v2/).

Si le nom du firmware contient le mot *boot*, il va falloir le "stripper"
(enlever le début qui correspond au boot). Pour faire ça :
```
# dd if=download_firmware(with_boot).bin of=6F01A8C0.img skip=257 bs=512
```
On note que le firmware est à renommer `6F01A8C0.img`.

On copie ensuite ce fichier dans le dossier du *tftp* :
```
# cp 6F01A8C0.img /srv/tftp/
```

Normalement, la taille de ce fichier est de 0x7c0000.

## Upload firmware usine

Maintenant que tout est prêt, on va pouvoir uploader le firmware. On branche
la connectique série et le câble réseau entre un port du routeur et
l'interface configurée précédemment sur le pc.

On allume le routeur et on tape `tpl` en boucle pour arrêter le processus de
boot et obtenir une console *ap135*.

On tape alors les commandes suivantes pour uploader le nouveau firmware :
```
ap135> tftp
ap135> erase 0x9f020000 +0x7c0000
ap135> cp.b 0x81000000 0x9f020000 0x7c0000
ap135> boot.m 0x9f020000
```

Si tout se passe bien, le routeur reboote sur le nouveau firmware et une
interface de configuration web est accessible ici : <http://192.168.0.1>. Les
identifiants par défaut sont `admin:admin`.

On peut maintenant installer proprement le firmware de son choix depuis cette interface.

## Sources

* <https://openwrt.org/toh/tp-link/tl-wr1043nd>
* <https://forum.dd-wrt.com/phpBB2/viewtopic.php?p=1012559>
* <https://www.cyberciti.biz/faq/install-configure-tftp-server-ubuntu-debian-howto/>
