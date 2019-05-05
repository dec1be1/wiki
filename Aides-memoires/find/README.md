find
====

La commande `find` permet de faire des recherches de fichiers ou dossiers dans l'arborescence. On peut aussi exécuter des commandes sur le résultat de la recherche.

Par exemple, pour chercher les fichiers correspondants à un certain `pattern` dans le répertoire courant :
 ```
$ find . -type f -name "pattern"
```

Si on veut en plus effacer ces fichiers (**les afficher seulement avec de supprimer...**) :
 ```
$ find . -type f -name "pattern" -exec rm "{}" \;
```
