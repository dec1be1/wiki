# Shred

Pour détruire des données dans les règles de l'art.

## Détruire un fichier

```
shred -vfu /file/to/shred
```

Le `-u` permet de supprimer le fichier après avoir écrit 3 passes (par défaut) 
de données aléatoires dessus.

Si le disque est chiffré, il ne faut pas mettre le `-z` de manière à ne pas 
écrire une passe de `0` à la fin. On peut le faire sur un disque non chiffré 
de manière à *masquer* le shred.

## Détruire un dossier entier

Pour détruire récursivement un dossier entier, on détruit d'abord chacun des 
fichiers, puis tous les sous-dossiers :
```
find /folder/to/shred -type f -exec shred -vfu "{}" \;
rm -rf /folder/to/shred
```

