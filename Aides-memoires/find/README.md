find
====

La commande `find` permet de faire des recherches de fichiers ou dossiers dans l'arborescence. On peut aussi exécuter des commandes sur le résultat de la recherche.

## Exemples
Par exemple, pour chercher les fichiers correspondants à un certain `pattern` dans le répertoire courant :
 ```
$ find . -type f -name "pattern"
```

Si on veut en plus effacer ces fichiers (**les afficher seulement avant de supprimer...**) :
 ```
$ find . -type f -name "pattern" -exec rm "{}" \;
```

Pour trouver les fichiers ou dossiers appartenant à l'utilisateur `jean-clode` (on évite aussi d'afficher les messages d'erreur) :
```
$ find / -user jean-clode 2>/dev/null
```
Pour les fichiers ou dossiers appartenant à un groupe, on remplace `-user` par `-group`.

## Sources
* https://www.cyberciti.biz/faq/how-do-i-find-all-the-files-owned-by-a-particular-user-or-group/
