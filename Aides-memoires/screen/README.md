screen
======

Créer un nouveau *screen* (et éventuellement lancer directement une commande
à l'intérieur) :
```
$ screen -S <nom_screen> [commande]
```

L'option `-dm` permet de lancer une nouvelle session sans s'y attacher
(pratique pour les scripts).

Pour détacher un screen du terminal, on peut taper `[CTRL]+a` puis `d`.
On peut aussi fermer directement la fenêtre de la console. Attention, si on
tape `exit` dans un screen, on tue le screen.

Pour lister les screens existants :
```
$ screen -ls
```

Pour attacher un screen existant au terminal :
```
$ screen -r <nom_screen>
```

Pour partager une session. Dans ce cas, on s'attache à une session déjà
attachée à un autre terminal et tout ce qui apparaît sur l'une apparaît sur
l'autre (pratique pour dépanner quelqu'un) :
```
$ screen -x <nom_screen>
```

Pour forcer le détachement d'un screen :
```
$ screen -d <nom_screen>
```

Pour supprimer les screens *dead* :
```
$ screen -wipe
```
