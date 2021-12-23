Compilation noyau sur Debian 9 (Stretch)
========================================

Cette page décrit la procédure de compilation du noyau Linux sous Debian 9
(Stretch).

## Installation des packages nécessaires
```
# apt install git build-essential libncurses5-dev xz-utils libelf-dev bc bison flex libssl-dev
```

## Téléchargement des sources

### Solution 1 : Téléchargement manuel

[Télécharger les sources et la signature](https://www.kernel.org),
vérifier la signature et décompresser l'archive.

### Solution 2 : Avec git

Pour ne cloner que la branche qui nous intéresse sans tout l'historique des
commit (qui prend beaucoup de place), on peut taper :
```
$ cd repertoire_source_kernel
$ git clone --depth 1 --single-branch --branch v4.14.61 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/ linux-4.14.61
```

## Préparation des sources

* Copier le fichier `.config` dans le dossier des sources.
* Entrer dans le dossier des sources.
* Taper :
```
$ make nconfig
```
* Charger le `.config` et faire ses modifications.
* Sauver le `.config` et quitter.
* Archiver le nouveau fichier de config en tapant :
```
$ cp ./.config /home/ju/geek/systems/Debian/kernel-config/mac/config-X.X.XX
```

## Compilation

* Taper les commandes suivantes :
```
$ make deb-pkg -j$(nproc)
$ cd ..
```
* Puis, en root :
```
# dpkg -i *deb
# reboot
```

## Post installation

Relancer une mise à jour des paquets. Le paquet `linux-libc-dev`
(qui avait été downgradé pendant l'installation du nouveau noyau) se remet à
jour :
```
# apt update && apt dist-upgrade
```

## Nettoyage

On peut supprimer les paquets des vieux noyaux (garder au moins un ancien
noyau fonctionnel...) avec :
```
# apt purge ...
```

## Sources

- <https://computerz.solutions/kernel-4-debian-8/>
