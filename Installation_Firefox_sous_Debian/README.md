Installation de Firefox sous Debian (paquet précompilé)
=======================================================

Ce wiki rappelle les étapes à suivre pour installer Firefox sur GNU/Linux (testé sur Debian Stretch) à partir du paquet précompilé. Cela permet d'avoir la dernière version de l'éditeur.

## Téléchargement des composants nécessaires
* Le paquet précompilé : depuis le site de l'éditeur https://www.mozilla.org/fr/firefox/new/

## Installation
On va faire l'installation dans le dossier `/opt/firefox`. Ainsi, tous les utilisateurs auront accès à l'application. On peut aussi faire une installation pour un utilisateur spécifique en copiant les fichiers dans son répertoire personnel.

* Décompresseur le paquet précompilé dans `/opt/firefox` (se placer avant dans le répertoire contenant le paquet) :
```
# tar xjf Firefox.tar.bz2 -C /opt/
```
* Ajuster les droits si nécessaire :
```
# chmod -R 755 /opt/firefox
```
* Pour que l'application apparaisse dans le menu d'applications, créer un fichier [`/usr/share/applications/firefox-stable.desktop`](./firefox-stable.desktop).

La session graphique devra être relancée pour prise en compte.

## Configuration de Firefox par défaut
Entrer les commandes suivantes :
```
# update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
# update-alternatives --set x-www-browser /opt/firefox/firefox
# update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /opt/firefox/firefox 200
# update-alternatives --set gnome-www-browser /opt/firefox/firefox
```

## Utilisation en ligne de commande
Pour pouvoir lancer Firefox en ligne de commande :
```
# ln -s /opt/firefox/firefox /usr/local/bin/
```

## Procédure de mise à jour
* Télécharger l'archive du paquet pré-compilé.
* Renommer le dossier `/opt/firefox` en `/opt/firefox.OLD` pour avoir une sauvegarde en cas de problème.
* Décompresser l'archive dans `/opt`
* Ajuster les droits des fichiers (755).
* Relancer les commandes de configuration de Firefox par défaut.

## Sources
* https://florent.poinsaut.fr/2018/03/02/installer-firefox-stable-debian-stretch/
