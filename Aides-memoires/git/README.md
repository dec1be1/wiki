git
===

**Toutes les commandes suivantes supposent qu'on se soit d'abord placé dans le répertoire local du dépôt (repository).**


#### Cloner un dépôt
```
$ git clone REPOSITORY.git
```

#### Lister les branches d'un dépôt
```
$ git tag -l
```

#### Afficher la branche en cours
```
$ git branch
```

#### Créer une nouvelle branche
```
$ git checkout -b testing
```

#### Changer de branche
```
$ git checkout v4.14.23
```

#### Mettre à jour un dépôt
```
$ git fetch
```

#### Afficher l’état du répertoire de travail par rapport au dépôt
```
$ git status
```

#### Remiser les modifications faites
```
$ git stash
```

#### Initialiser un nouveau dépôt
```
$ git init
```

#### Ajouter un fichier à l'index du dépôt
```
$ git add fichier
```

#### Ajouter tous les fichiers créés ou modifiés à l'index du dépôt
```
$ git add --all
```

#### Faire un commit
```
$ git commit -m "commit message"
```

#### Afficher la liste des commit
```
$ git log
```

#### Ajouter un remote (ici *origin*) au dépôt en ssh
```
$ git remote add origin git@gitlab.com:ju6a75/hello-world.git
```

Il faut ici un accès *ssh* au dépôt (sur [FramaGit](https://framagit.org), avoir ajouté un clé publique *ssh* dans les paramètres du compte).

#### Renommer un remote
```
$ git remote rename origin old-origin
```

#### Push
Pour *pusher* les modifications commitées vers le dépôt distant (remplacer `master` par `--all` pour pusher toutes les branches) :
```
$ git push -u origin master
```

#### Pull
Pour récupérer dans le dépôt local les modifications du dépôt distant (remplacer `master` par `--all` pour puller toutes les branches) :
```
$ git pull origin master
```

Si, lors d'un `git pull`, on obtient une erreur *Veuillez valider ou remiser vos modifications avant la fusion*, on peut corriger le problème avec cette commande :
```
$ git reset --hard HEAD
```
