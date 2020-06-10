Installation OpenBSD sur un serveur distant Kimsufi
===================================================
Testé avec OpenBSD 6.5 sur serveur Kimsufi KS-6 (Intel i5-750 - 16GB DDR3 1333 MHz - 2To SATA).

## Première installation
### Système d'origine
On installe depuis l'interface web de gestion un système classique. Ici *Debian 9*.
On suit les instructions.

### Reboot en mode rescue
Depuis l'interface web de gestion, redémarrer en mode *rescue* :
* Cliquer sur *Netboot*
* Puis sur *Rescue*
* Choisir le mode *rescue64-pro*

Au bout de quelques instants, on reçoit un mail avec les identifiants de connexion à utiliser.
On se connecte en ssh :
```
# ssh root@176.31.100.127
[...]
root@ns389060:~# export TERM=xterm-color
```

### Préparation de l'installation
On installe *qemu* : `apt update` puis `apt install qemu`.
On télécharge l'image iso d'OpenBSD, les sommes de contrôle et on vérifie :
```
root@ns389060:~# wget https://cdn.openbsd.org/pub/OpenBSD/6.5/amd64/install65.iso
root@ns389060:~# wget https://cdn.openbsd.org/pub/OpenBSD/6.5/amd64/SHA256
root@ns389060:~# sha256sum -c --ignore-missing SHA256
```

Si c'est ok, on passe à la suite.

### Lancement de qemu
On lance qemu :
```
root@ns389060:~# qemu-system-x86_64 -drive format=raw,file=/dev/sda,cache=none,if=virtio -cdrom ./install65.iso -boot d -curses -k fr -smp $(nproc)
```

### Installation d'OpenBSD
On installe OpenBSD de manière classique (avec certaines partitions chiffrées). Pour chiffrer les partitions importantes (on ne peut pas tout chiffrer car on veut éviter d'avoir à taper une passphrase au boot) :
* on ouvre un shell lors de l'install **avant** de partitionner le disque.
* on crée une table des partitions : `# fdisk -iy sd0`
* on crée le disklabel et on partitionne : `# disklabel -E sd0`

Pour mémoire, le layout utilisé (on ajoute les tailles de chaque partition sur la dernière colonne ; la dernière est celle qui va accueillir les partitions chiffrées) :
```
sd0> p
OpenBSD area: 64-3907024065; size: 3907024001; free: 5
#                size           offset  fstype [fsize bsize   cpg]
 a:          4208960               64  4.2BSD   2048 16384     1    2g
 b:         16787931          4209024    swap                       8g
 c:       3907029168                0  unused
 d:         10490432         20996960  4.2BSD   2048 16384     1    5g
 e:          8401984         31487392  4.2BSD   2048 16384     1    4g
 f:          8401984         39889376  4.2BSD   2048 16384     1    4g
 g:          2104544         48291360  4.2BSD   2048 16384     1    1g
 h:         20980864         50395904  4.2BSD   2048 16384     1    10g
 i:            32128         71376768  4.2BSD   2048 16384     1    10m
 j:          4209056         71408896  4.2BSD   2048 16384     1    2g
 k:          8401984         75617952  4.2BSD   2048 16384     1    4g
 l:       3823004129         84019936    RAID                       Le reste
```

On note que les points de montage ne sont pas encore affectés.
On sauve on quitte disklabel.

On crée maintenant le volume chiffré sur la partition `sd0l` : `# bioctl -c C -l sd0l softraid0`

On suit le tuto sur le site d'OpenBSD :
```
# cd /dev && sh MAKEDEV sd1
# dd if=/dev/zero of=/dev/rsd1c bs=1m count=1
```

On partition le disque chiffré (`sd1`) :
```
# fdisk -iy sd1
# disklabel -E sd1
```

Le layout des partitions chiffrées :
```
sd1> p
OpenBSD area: 64-3822988050; size: 3822987986; free: 50
#                size           offset  fstype [fsize bsize   cpg]
 a:        209728480               64  4.2BSD   2048 16384     1    100g    /var/vmail
 b:        209728576        209728544  4.2BSD   2048 16384     1    100g    /var/www
 c:       3823003601                0  unused
 d:       3403530880        419457152  4.2BSD   8192 65536     1    Le reste    /mnt/data
```
On écrit le label, on quitte et on reprend l'installation (`exit`).

On reprend l'installation et on ajoute les points de montage :
```
sd0> p
OpenBSD area: 64-3907024065; size: 3907024001; free: 5
#                size           offset  fstype [fsize bsize   cpg]
 a:          4208960               64  4.2BSD   2048 16384     1 # /
 b:         16787931          4209024    swap
 c:       3907029168                0  unused
 d:         10490432         20996960  4.2BSD   2048 16384     1 # /home
 e:          8401984         31487392  4.2BSD   2048 16384     1 # /tmp
 f:          8401984         39889376  4.2BSD   2048 16384     1 # /usr
 g:          2104544         48291360  4.2BSD   2048 16384     1 # /usr/X11R6
 h:         20980864         50395904  4.2BSD   2048 16384     1 # /usr/local
 i:            32128         71376768  4.2BSD   2048 16384     1 # /usr/obj
 j:          4209056         71408896  4.2BSD   2048 16384     1 # /usr/src
 k:          8401984         75617952  4.2BSD   2048 16384     1 # /var
 l:       3823004129         84019936    RAID
```

On fait pareil pour `sd1` (voir layout au dessus).
Les systèmes de fichiers sont créés.

On installe les packages puis on lance un shell quand c'est proposé.
En effet, pour éviter une erreur au boot, il faut commenter les partitions chiffrées dans le `/etc/fstab`. On peut obtenir un shell en faisant Ctrl+C. On sortira du shell pour reprendre l'install avec `exit`.

On finit l'installation normalement puis on passe à la configuration (notamment script *post-boot*).

Pour sortir de qemu : Alt+Shift+2 puis `quit`.

### Test ou dépannage
Avant de faire un reboot à l'aveugle ou pour dépanner, on peut tester le systèm en bootant sur le disque du serveur avec *Qemu* :
```
root@ns389060:~# qemu-system-x86_64 -drive format=raw,file=/dev/sda,cache=none,if=virtio -curses -k fr -smp $(nproc)
```

Pour remapper correctement le clavier en français : `# wsconsctl keyboard.encoding=fr`.

### Rebooter sur le nouveau système
Ca se passe avec l'interface web de gestion. Il faut avoir fait un `halt` depuis OpenBSD. Ensuite :
* cliquer sur *Netboot*
* cliquer sur *Hard disk*
* puis *Next* et confirmer
* taper `reboot` depuis la console *rescue*

Après quelques instants, le serveur devrait être accessible par ssh.
Ne pas oublier les mises à jour de sécurité avec `syspatch` dès que possible !

## Mise à jour
### Préparation
On se connecte en ssh au serveur et on fait les étapes *pre-upgrade* décrites dans la page d'upgrade de la [FAQ d'OpenBSD](https://www.openbsd.org/faq/index.html).
Il faut notamment télécharger sur le serveur le noyau ramdisk *bsd.rd* de la nouvelle version pour booter dessus ensuite.

Arrêter le serveur proprement.

### Redémarrage en mode *rescue*
Depuis l'interface web de gestion, redémarrer en mode *rescue* :
* Cliquer sur *Netboot*
* Puis sur *Rescue*
* Choisir le mode *rescue64-pro*

Au bout de quelques instants, on reçoit un mail avec les identifiants de connexion à utiliser (on peut consulter les mails envoyés par Kimsufi depuis l'interface web).
On se connecte en ssh :
```
# ssh root@176.31.100.127
[...]
root@ns389060:~# export TERM=xterm-color
```

### Lancement de qemu
On installe qemu et on le lance en bootant sur le disque dur du serveur :
```
root@ns389060:~# apt update
root@ns389060:~# apt install qemu
root@ns389060:~# qemu-system-x86_64 -drive format=raw,file=/dev/sda,cache=none,if=virtio -curses -k fr -smp $(nproc)
```

Au prompt `boot>`, on demande à booter sur le noyau `bsd.rd`.

### Mise à jour OpenBSD
On poursuit la procédure de la page d'upgrade de la [FAQ d'OpenBSD](https://www.openbsd.org/faq/index.html).

> On note que les partitions chiffrées n'ont pas besoin d'être montées durant l'upgrade, ce qui simplifie la procédure.

Une fois l'upgrade terminé, rebooter sur le nouveau noyau pour vérifier que tout va bien. En profiter pour vérifier le fonctionnement du firewall.

### Rebooter sur le nouveau système
Ca se passe avec l'interface web de gestion. Il faut avoir fait un `halt` depuis OpenBSD. Ensuite :
* cliquer sur *Netboot*
* cliquer sur *Hard disk*
* puis *Next* et confirmer
* taper `reboot` depuis la console *rescue*

Après quelques instants, le serveur devrait être accessible par ssh.

Terminer le processus d'installation en suivant la [FAQ d'OpenBSD](https://www.openbsd.org/faq/index.html).

## Sources
* https://www.tumfatig.net/20190510/running-openbsd-6-5-on-kimsufi-ks-10/
* https://github.com/dodoritfort/OpenBSD/wiki/Installer-OpenBSD-sur-votre-serveur-Kimsufi
* https://blog.meseira.net/post/2016/12/21/install-openbsd-kimsufi/
