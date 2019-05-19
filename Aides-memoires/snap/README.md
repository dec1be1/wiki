snap
====

Il s'agit d'un gestionnaire de paquets indépendant de la distribution GNU/Linux utilisée. Chaque paquet embarque toutes les dépendances nécessaires.
Cela permet d'installer les dernières versions de paquets supportés. Pratique sous Debian par exemple puisque ça permet d'éviter de jongler avec les dépôts *unstable* ou *testing* pour installer une version récente d'un logiciel.
Site officiel : https://snapcraft.io

Pour installer un paquet :
 ```
# snap install PAQUET
```

Pour mettre à jour tous les paquets installés :
 ```
# snap refresh
```

Pour supprimer un paquet :
 ```
# snap remove PAQUET
```

Pour afficher les paquets installés :
 ```
$ snap list
```

Pour chercher un paquet contenant PATTERN :
 ```
$ snap find PATTERN
```
