git
===

**Toutes les commandes suivantes supposent qu'on se soit d'abord placé dans le répertoire local du dépôt (repository).**

## Dépôts
### Initialiser un nouveau dépôt
```
$ git init
```

### Voir les dépôts distants
```
$ git remote -v
```

### Ajouter un dépôt distant
```
$ git remote add <remote_name> <repo_url>
```

> `git remote rename` pour renommer un dépôt distant
> `git remote remove` pour supprimer un dépôt distant

### Avoir des informations sur un dépôt distant
```
$ git remote show <remote_name>
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

### Changer les droits d'un fichier après indexation
Si on veut changer les droits d'un fichier après l'avoir indexé (par exemple 
ajouter les droits d'exécution pour un script), il faut :

- Changer les droits de manière normale : `chmod +x file`.
- Mettre à jour l'index : `git update-index --chmod=+x file`.

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
> Option `--graph` pour avoir une représentation graphique.

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

### Afficher l’état du répertoire de travail par rapport au dépôt
```
$ git status
```

> `-s` pour un affichage plus court.

### Afficher les différences entre les fichiers indexés et non indexés
```
$ git diff
```

### Push
Pour *pusher* les modifications commitées vers le dépôt distant (remplacer `master` par `--all` pour pusher toutes les branches) :
```
$ git push origin master
```

### Pull
Pour récupérer dans le dépôt local les modifications de la branche `master` du dépôt distant `origin` (remplacer `master` par `--all` pour puller toutes les branches) :
```
$ git pull origin master
```

> `git pull` est en fait la combinaison d'un `git fetch` (pour récupérer les commits) et d'un `git merge` (pour les fusionner dans la branche courante et créer un nouveau commit).

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







## Branches
Une branche est une suite de commits.

### Lister les branches d'un dépôt (et afficher la branche en cours)
```
$ git branch
```

> Option `-a` pour voir également les branches distantes présentes dans le dépôt local.
> Option `-vv` pour voir les branches suivies. Pour changer la branche suivie : `git branch -u origin/<branch>`.

### Créer une nouvelle branche (en restant sur la branche en cours)
```
$ git branch new_branch
```

### Créer une nouvelle branche et basculer directement dessus
```
$ git checkout -b testing
```

> Attention à créer la nouvelle branche depuis le bon endroit (changer la branche courante si nécessaire).

### Créer une branche locale depuis une branche distante
Cela revient à faire une copie locale d'une branche distante :
```
$ git checkout -b <branch> origin/<branch>
```

### Changer de branche
```
$ git checkout v4.14.23
```

> On déplace le pointeur `HEAD` et les fichiers du répertoire de travail deviennent ceux du snapshot pointé par le dernier commit de la branche.

### Récupérer les commits d'une branche distante vers la branche locale
Par exemple de `origin/master` vers `master` :
```
$ git fetch
```

> Cela permet de récupérer les commits d'une branche (en général *origin/master*) dans le dépôt local pour les examiner (et éventuellement faire des modifications) avant de fusionner avec une branche de travail en cours. Utile lorsque la branche principale d'un projet évolue pendant qu'on travaille sur ses propres branches. On récupère alors les commits distants de la branche principale dans son dépôt local avant de fusionner cette branche principale avec sa propre branche (des conflits peuvent alors être à gérer manuellement).

> **Attention :** Lorsqu'on récupère une nouvelle branche distante avec fetch, on ne récupère pas une copie éditable de la branche mais seulement un pointeur vers la branche distante. Il faut merger avec sa branche en cours : `git merge origin/<branch>`.

### Fusionner les commits d'une branche avec la branche en cours
```
$ git merge <branch>
```

S'il y a continuité des commits entre les deux branches fusionnées, git va simplement déplacer le pointeur de la branche en cours sur celui de la branche à fusionner. C'est une fusion *Fast-Forward*. On peut supprimer la branche mergée si on n'en a plus besoin.

Dans le cas contraire, git va faire la fusion et créer un nouveau commit (*merge commit*) dans la branche en cours. En effet, on ne peut pas simplement déplacer le pointeur de la branche en cours car les modifications sont issues d'au moins deux branches divergentes. C'est une fusion de type *recursive*. Il peut y avoir des conflits à gérer dans ce cas. S'il y en a, on note que le merge est fait dans tous les cas. On résout les conflits manuellement puis on commit les modifications (pas besoin de refaire le merge).

### Voir les branches fusionnées ou non
```
$ git branch --merged
$ git branch --no-merged
```

### Supprimer une branche
```
$ git branch -d <branch_to_delete>
```
> Si la branche n'est pas totalement fusionnée, on aura un avertissement. On peut forcer la suppression avec `-D`. **Attention, dans ce cas, on perd toutes les modifications faites dans la branche**.

Pour une branche distante :
```
$ git push origin --delete <branch_to_delete>
```

### Rebase
Lorsqu'on travail en local (avant de faire des pushs "propres"), il est plus clair de faire un `git rebase` plutôt qu'un `git merge`. En effet, le `git rebase` permet de transposer les commits faits sur une branche vers une autre (*master* par exemple). On garde donc l'historique des commits mais dans la nouvelle branche. **Ne jamais rebaser des commits poussés sur un dépôt public**. 

L'option `-i` permet de faire un *rebase interactif*. Très utile pour nettoyer son historique avant de faire un push.

Exemple pour lancer un rebase interactif sur les 3 derniers commits de la branche en cours : 
```
$ git rebase -i HEAD~3
```






## Tags
### Lister les tags
```
$ git tag
```

> Deux types de tag :
> - léger (juste un pointeur sur un commit)
> - annoté avec `-a` (un objet git à part entière)

### Créer un tag annoté
Sur le dernier commit réalisé (**attention à être dans la bonne branche**) :
```
$ git tag -a <tag_name> -m "Annotation du tag"
```

Sur un commit particulier :
```
$ git tag -a <tag_name> -m "Annotation du tag" <commit_hash>
```

### Voir les informations sur un tag
```
$ git show <tag_name>
```

### Récupérer tous les tags depuis un dépôt distant
```
$ git fetch --tags --all
```

> Si on ne met pas le `--all`, on ne récupère que le dernier tag.

### Se placer sur un tag particulier
```
$ git checkout <tag_name>
```

### Créer une nouvelle branche basée sur un tag
```
$ git checkout -b <new_branch_name> <tag_name>
```

### Pousser un tag
Pour pousser un tag sur le dépôt distant :
```
$ git push origin <tag_name>
```

Pour pousser tous les nouveaux tags d'un coup :
```
$ git push origin --tags
```

### Effacer un tag
En local :
```
$ git tag -d <tag_name>
```

Sur le dépôt distant :
```
$ git push --delete origin <tag_name>
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

> Pour rappel, `HEAD` est un pointeur vers la position actuelle dans le répertoire de travail (branche en cours et dernier commit).

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

