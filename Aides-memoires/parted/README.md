parted
======

Commandes à taper dans le shell de `parted`.

Pour choisir le périphérique (`/dev/sdb` par exemple) :
```
(parted) select /dev/sdb
```

Pour afficher la table de partitions (après avoir sélectionner un
périphérique) :
 ```
(parted) print
```

Pour ajouter les flags `boot` et `esp` à une partition (la numéro `1` par
exemple) :
 ```
(parted) set 1 boot on
```
Dans ce cas, le flag `esp` se met automatiquement.
