# du

Pour afficher la taille du répertoire courant :
```
du -sh
```

Pour afficher la taille des fichiers et sous-répertoires du dossier courant,
dans l’ordre décroissant de taille:
```
du -a --max-depth=1 | sort -nr
```
