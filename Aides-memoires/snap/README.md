# snap

Il s'agit d'un gestionnaire de paquets indépendant de la distribution
GNU/Linux utilisée. Chaque paquet embarque toutes les dépendances nécessaires.
Cela permet d'installer les dernières versions de paquets supportés.
Pratique sous Debian par exemple puisque ça permet d'éviter de jongler avec
les dépôts *unstable* ou *testing* pour installer une version récente d'un
logiciel.

Site officiel : <https://snapcraft.io>

Pour installer un paquet :
 ```
sudo snap install PAQUET
```

Pour mettre à jour tous les paquets installés :
 ```
sudo snap refresh
```

Pour supprimer un paquet :
 ```
sudo snap remove PAQUET
```

Pour afficher les paquets installés :
 ```
sudo snap list
```

Pour chercher un paquet contenant PATTERN :
 ```
sudo snap find PATTERN
```
