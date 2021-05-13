hashcat
=======

On suppose ici qu'on a une installation de *hashcat* qu'on va utiliser avec
un GPU *nvidia* (avec le framework *CUDA*).

Sous Linux, les drivers nvidia sont installés avec *bumblebee*. Il faut
ajouter `optirun` avant toutes commandes lorsqu'on veut utiliser le GPU.

Pour voir les backends de calculs disponibles :
```
$ optirun hashcat -I
```

Pour lancer un calcul :
```
$ optirun hashcat -m 1000 \
                  -a 0 \
                  -d 1,2,3 \
                  --session <session_name> \
                  <hash_file_path> \
                  <wordlist_path>
```

- `-m` : le type de hash à cracker
- `-a` : le type de crack
- `-d` : les devices de calcul à utiliser (utiliser `-I` pour les lister)
- `--session` : pour nommer la session actuelle et pouvoir la restaurer
                si elle s'arrête (création d'un fichier `.restore`).

Pour le mettre en pause proprement, choisir *Checkpoint* en appuyant sur `c`.
Cela arrêtera l'opération après la prochaine écriture dans le fichier
`.restore`. Si on quitte avec `q` ou que l'opération s'arrête brutalement,
on pourra quand même restaurer la session (les mots de passe passés depuis
le dernier checkpoint devront juste être retestés).

Pour relancer une session existante :
```
$ optirun hashcat --session <session_name> --restore
```

> Si on ne met pas `--session`, le fichier de session est enregistré
  par defaut dans le fichier `~/.hashcat/hashcat.restore`. Dans ce cas, pas
  besoin de spécifier `--session` pour restaurer la session.
