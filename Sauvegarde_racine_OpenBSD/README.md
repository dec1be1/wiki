Sauvegarde de la partition racine sous OpenBSD (`/altroot`)
==========================================================

Le but est de sauvegarder régulièrement (quotidiennement ici), la partition racine `/` du système dans une partition créée pour l'occasion (`/altroot`). La sauvegarde se fait avec `dd`. Il faut donc que la partition `/altroot` soit au moins aussi grande que la partition `/`.

# Configuration de la sauvegarde
## Préparation du disque dur de sauvegarde
Le mieux est de dédier un disque dur (qui pourra booter) pour cette tâche.

On repère le nom du device. On choisira ici `sd1`. On initialise le disque avec `fdisk` :
```
# fdisk -i sd1
```

On crée le `disklabel` :
```
# disklabel -E sd1
```

Puis, dans `disklabel` :
* on efface tout : `> z`
* on ajoute une seule partition `a` : `> a a`
* on vérifie : `> p`
* on applique les changements et on sort : `> q`

On crée le système de fichier sur la partition :
```
# newfs sd1a
```

On repère le `duid` de la partition :
```
# sysctl hw.disknames
sd1:5dc1e396ebe437a3
```

## Mise en place de la sauvegarde
On ajoute cette ligne dans le fichier `/etc/fstab` :
```
5dc1e396ebe437a3.a /altroot ffs xx 0 0
```

On crée le crontab quotidienne :
```
# echo ROOTBACKUP=1 >> /etc/daily.local
```

# En cas de problème
Si l'ordinateur ne boote plus sur la partition racine initiale, on peut tenter de booter sur la sauvegarde. Pour ça, on tape au boot :
```
boot > set device sd1a
boot > boot -s
```

On peut taper ça au boot pour savoir quelle est la partition `altroot` :
```
boot > machine diskinfo
```
