git
===

**Toutes les commandes suivantes supposent qu'on se soit d'abord placé dans le répertoire local du dépôt (repository).**

## Commandes
### Initialiser un nouveau dépôt
```
$ git init
```

### Ajouter un fichier à l'index du dépôt (working directory -> stage)
```
$ git add fichier
```

### Ajouter tous les fichiers créés ou modifiés à l'index du dépôt
```
$ git add --all
```

### Supprimer un fichier du dépôt
Il faut le dé-indexer avant de le supprimer :
```
$ git rm <file>
```

### Faire un commit (stage -> repository)
```
$ git commit -m "commit description"
```

> Option `-v` pour ajouter le diff au commentaire du commit. 
> Option `-a` pour ajouter directement les fichiers **déjà** suivis (*tracked*) à l'index.

### Afficher les commits
```
$ git log
```

> Option `--pretty=...` pour personnaliser la sortie.

### Afficher les commits et les actions réalisées
```
$ git reflog
```

### Pour revenir à un commit ou une action donnée
```
$ git checkout <hash>
```

### Pour voir les modifications faites sur un fichier
```
$ git blame file.txt
```

### Ajouter un remote (ici *origin*) au dépôt en ssh
```
$ git remote add origin git@gitlab.com:ju6a75/hello-world.git
```

Il faut ici un accès *ssh* au dépôt (sur [FramaGit](https://framagit.org), avoir ajouté un clé publique *ssh* dans les paramètres du compte).

### Renommer un remote
```
$ git remote rename origin old-origin
```

### Cloner un dépôt
```
$ git clone REPOSITORY.git
```

### Lister les branches d'un dépôt (et afficher la branche en cours)
```
$ git branch
```

### Créer une nouvelle branche (en restant sur la branche en cours)
```
$ git branch new_branch
```

### Créer une nouvelle branche et basculer directement dessus
```
$ git checkout -b testing
```

### Changer de branche
```
$ git checkout v4.14.23
```

### Récupérer les commits d'une branche distante vers la branche locale
```
$ git fetch
```

> Cela permet de récupérer les commits d'une branche (en général *master*) dans le dépôt local pour les examiner (et éventuellement faire des modifications) avant de fusionner avec une branche de travail en cours. Utile lorsque la branche principale d'un projet évolue pendant qu'on travaille sur ses propres branches. On récupère alors les commits distants de la branche principale dans son dépôt local avant de fusionner cette branche principale avec sa propre branche (des conflits peuvent alors être à gérer manuellement).

### Fusionner les commits d'une branche avec la branche en cours
```
$ git merge <branch>
```

> Cela crée également un nouveau commit dans la branche en cours.

### Rebase
Lorsqu'on travail en local (avant de faire des pushs "propres"), il est plus clair de faire un `git rebase` plutôt qu'un `git merge`. En effet, le `git rebase` permet de transposer les commits faits sur une branche vers une autre (*master* par exemple). On garde donc l'historique des commits mais dans la nouvelle branche. **A ne pas faire sur un dépôt public**. 

L'option `-i` permet de faire un *rebase interactif*. Très utile pour nettoyer son historique avant de faire un push.

Exemple pour lancer un rebase interactif sur les 3 derniers commits de la branche en cours : 
```
$ git rebase -i HEAD~3
```

### Afficher l’état du répertoire de travail par rapport au dépôt
```
$ git status
```

> `-s` pour un affichage plus court.

### Afficher les différences entre les fichiers indexés et non indexés
```
$ git diff
```

### Remiser les modifications faites (la branche en cours redevient "propre")
```
$ git stash
```

### Lister les remises en cours
```
$ git stash list
```

### Appliquer une remise à la branche en cours
```
$ git stash apply [stash_name]
```

### Push
Pour *pusher* les modifications commitées vers le dépôt distant (remplacer `master` par `--all` pour pusher toutes les branches) :
```
$ git push -u origin master
```

### Pull
Pour récupérer dans le dépôt local les modifications du dépôt distant (remplacer `master` par `--all` pour puller toutes les branches) :
```
$ git pull origin master
```

> `git pull` est en fait la combinaison d'un `git fetch` (pour récupérer les commits) et d'un `git merge` (pour les fusionner dans la branche courante et créer un nouveau commit).

### Créer un tag (étiquette annotée)
Sur le dernier commit réalisé (**attention à être dans la bonne branche**) :
```
$ git tag -a nom-du-tag -m "Annotation du tag"
```

Sur un commit particulier :
```
$ git tag -a nom-du-tag -m "Annotation du tag" <hash du commit>
```
### Pousser un tag
Pour pousser un tag sur le dépôt distant :
```
$ git push origin nom-du-tag
```

Pour pousser tous les nouveaux tags d'un coup :
```
$ git push origin --tags
```

### Effacer un tag
En local :
```
$ git tag -d nom-du-tag
```

Sur le dépôt distant :
```
$ git push --delete origin nom-du-tag
```

## gitignore
Des modèles de `.gitignore` sont disponibles pour différents langages : <https://github.com/github/gitignore>

## Correction des erreurs
### Supprimer une branche

Si la branche vient d'être créée (pas de modifications faites) :
```
$ git branch -d new_branch
```

Si des modifications ont été faites, on peut, avant de supprimer la branche :

- Soit commiter les modifications.
- Soit remiser les modifications.
- Soit forcer la suppression de la branche (avec `-D`). Dans ce cas, on supprime aussi tous les fichiers et modifications non commités de la branche.

### Modifications faites dans une mauvaise branche

Dans le cas où on modifie par erreur une branche (on a par exemple oublié de créer une nouvelle branche pour les modifications en cours), on peut revenir en arrière.

#### Cas de modifications non commitées

- Remiser les modifications en cours pour quela branche en cours redevient propre : `git stash`
- Créer la nouvelle branche et basculer dessus : `git checkout -b new_branch`
- Appliquer la remise à la nouvelle branche : `git stash apply`

#### Cas de modifications commitées

On va pouvoir annuler le dernier commit de la manière suivante :

- Identifier le hash du commit : `git log`
- Supprimer le dernier commit de la branche : `git reset --hard HEAD^`
- Créer et basculer sur la nouvelle branche : `git checkout -b new_branch`
- Appliquer le commit fautif sur la nouvelle branche : `git reset --hard <commit_hash>`

### Modifier le message du dernier commit réalisé
```
$ git commit --amend -m "nouveau message"
```

### Ajouter un fichier au dernier commit réalisé

- On ajoute le fichier oublié : `git add forgotten.file`
- On ajoute le fichier au dernier commit (`--no-edit` permet de ne pas modifier le message du commit) : `git commit --amend --no-edit`

> D'une manière plus générale, `--amend` permet de modifier le dernier commit réalisé en appliquant des modifications (faites après le commit donc). Si aucun changement n'est en attente, on peut modifier le message avec `-m`.

### Annuler son dernier commit public (après un push)

**Prévenir ses copains !!!**

```
$ git revert HEAD
```

Cela va créer un nouveau commit qui annule les modifications du commit fautif. On peut alors pusher ce nouveau commit.

> Il n'y a aucune perte de l'historique avec `git revert` contrairement à la version `--hard` de `git reset`.

### `git reset`
Cette commande permet d'annuler des changements pour revenir à une version précédente du projet. Elle compte trois niveaux : `--soft`, `--mixed` et `--hard`.

Pour revenir à un commit donné sans rien effacer (on peut par exemple créer une nouvelle branche depuis ce commit ou juste voir le code) :
```
$ git reset --soft <commit_hash>
```

Pour supprimer le dernier commit mais en gardant les modifications de ce commit dans le répertoire de travail :
```
$ git reset --mixed HEAD^
```

> Pour rappel, `HEAD` est un pointeur vers la position actuelle dans le répertoire de travail.

Pour supprimer tous les commits faits après un commit donné (**attention : aucune possibilité de revenir en arrière** :
```
$ git reset --hard <commit_hash>
```

Ou juste pour le dernier commit :
```
$ git reset --hard HEAD^
```

### Résolution des conflits
Lors de la fusion de branches, on peut avoir des conflits que git va afficher. On les corrige à la main puis lorsque c'est fini : `git commit`.







## Sources

- <http://dauzon.com/lire-Git-Supprimer-ou-remplacer-le-dernier-commit-43>
- <https://openclassrooms.com/fr/courses/5641721-utilisez-git-et-github-pour-vos-projets-de-developpement>

