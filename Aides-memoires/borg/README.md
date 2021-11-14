# borg

*borg* est une solution de backup qui permet de compresser/chiffrer les
données. *borg* découpe les fichiers en *chunks*, ce qui est
particulièrement efficace pour les gros fichiers.

## Commandes utiles

> Pour les sauvegardes distantes via ssh, on note qu'on peut utiliser
  directement un alias défini dans sa configuration ssh (au lieu de
  `username@hostname`).

### Initialisation

Initialiser un nouveau repo borg (distant via ssh et avec chiffrement) :
```
borg init -e repokey ssh://username@hostname/path/to/repo/repo_name
```

Exporter la clé de chiffrement dans un fichier local
(à sauvegarder en lieu sûr avec la passphrase) :
```
borg key export ssh://username@hostname/path/to/repo/repo_name /path/to/localfile
```

### Création d'une archive

Ca se fait à l'air de la commande `borg create` mais on préfèrera
l'utilisation d'un petit script *bash*. Voici un [exemple](./borg_backup.sh).

### Informations

Obtenir des informations sur un repo :
```
borg info ssh://username@hostname/path/to/repo/repo_name
```

Lister les archives disponibles sur un repo :
```
borg list ssh://username@hostname/path/to/repo/repo_name
```

Lister le contenu d'une archive :
```
borg list ssh://username@hostname/path/to/repo/repo_name::archive_name
```

### Restauration

> Il faut avoir le paquet `python-llfuse`.

Pour monter un repo (chaque archive sera dans un dossier séparé) :
```
borg mount ssh://username@hostname/path/to/repo/repo_name /local/mountpoint
```

Pour démonter :
```
borg umount /local/mountpoint
```

Pour extraire entièrement une archive **dans le répertoire courant** :
```
borg extract ssh://username@hostname/path/to/repo/repo_name::archive_name
```

Pour extraire seulement un dossier d'une archive :
```
borg extract ssh://username@hostname/path/to/repo/repo_name::archive_name specific_path/
```

## Sources

- <https://borgbackup.readthedocs.io/en/stable/>
- <https://ouafnico.shivaserv.fr/posts/geek-borg/>
- <https://doc.ubuntu-fr.org/borgbackup>
