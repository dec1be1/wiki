vim
===

## Fichiers

En mode interactif :

- pour ouvrir un nouveau fichier à la place d'un autre (le fichier ouvert doit avoir été sauvé) : `:e`
- utiliser la commande `:r CheminFichierAInserer` pour insérer un fichier à la position du curseur.

## Déplacement

En mode interactif :

- début de ligne : `0`
- fin de ligne : `$`
- de mot en mot : `w` (début du mot), `e` (fin du mot)
- au début du mot (puis début du mot précédent) : `b`
- sauter à la ligne n°14 : `14G`
- sauter à la première ligne : `G`
- sauter à la dernière ligne : `gg`

## Insertion

- passer en mode d'insertion de texte à partir du curseur : `i`.
- insérer une nouvelle ligne après la ligne du curseur (et passer en mode insertion) : `o`
- insérer à la fin de la ligne : `A`

## Indentation

Depuis le mode visuel :

- ajouter indentation : `>`
- enlever indentation : `<`

## Suppression

En mode interactif :

- le caractère sur le curseur : `x`
- le caractère juste avant le curseur : `X`
- du curseur au prochain espace : `dw`
- le mot sous le curseur : `diw`
- 3 mots : `3dw`
- une ligne : `dd`
- 2 lignes : `2dd`
- du curseur jusqu'au début de la ligne : `d0`
- du curseur jusqu'à la fin de la ligne : `d$`

## Copier / Coller

En mode interactif :

- copier la ligne courante en mémoire : `yy`
- copier 4 lignes en mémoire : `4yy`
- copier un mot en mémoire : `yw`
- copier du curseur jusqu'à la fin de la ligne : `y$`
- couper la ligne courante en mémoire : `dd`
- coller la ligne située en mémoire (sur la ligne située après le curseur) : `p`
- coller 4 fois la ligne en mémoire : `4p`

## Mode visuel

Ce mode permet de sélectionner une partie du texte à l'aide des flèches. On accède à ce mode depuis le mode interactif avec `v`.

On peut sélectionner une colonne particulière (sur un nombre arbitraire de lignes) avec `Ctrl+v` depuis le mode interactif.

## Annulation

En mode interactif :

- annuler la dernière action : `u`
- annuler les 3 dernières actions : `3u`
- annuler l'annulation : `Ctrl+r`

## Rechercher / Remplacer
### Rechercher

Depuis le mode interactif, taper `/` pour passer en *mode recherche*.

- taper le mot à rechercher puis `Enter` pour trouver la première occurrence.
- `n` : parcourir les occurrences suivantes
- `N` : parcourir les occurrences précédentes

> Note : pour faire une recherche vers le début du fichier, taper `?` au lieu de `/`.

### Remplacer

- remplacer la première occurrence de la ligne du curseur : `:s/ancien/nouveau`
- remplacer toutes les occurrences de la ligne du curseur : `:s/ancien/nouveau/g`
- remplacer toutes les occurrences entre les lignes 6 et 42 : `:6,42s/ancien/nouveau/g`
- remplacer toutes les occurrences dans le fichier entier : `:%s/ancien/nouveau/g`

### Commentaires

- commenter les lignes 3 à 8 (avec le caractère `#` par exemple) : `:3,8s/^/# `
- décommenter l'exemple précédent : `:3,8s/^# //`

> Note : l'autocomplétion fonctionne dans la barre de commande de *vim*.

## Découpage d'écran (split)

### Découpage

- découper l'écran horizontalement : `:sp` ou `Ctrl+w` puis `s`
- découper l'écran verticalement : `:vsp` ou `Ctrl+w` puis `v`
- ouvrir une nouvelle vue (vide) : `Ctrl+w` puis `n`

> Note : Par défaut, c'est le même fichier qui est ouvert. On peut spécifier le chemin du fichier à ouvrir à la suite de la commande.

### Gestion des vues

- naviguer de vue en vue : `Ctrl` + `w` plusieurs fois
- déplacer le curseur vers la vue en dessous : `Ctrl+w` puis `j` (au dessus : `k`, à gauche : `h`, à droite : `l`)
- zoom sur la vue actuelle : `Ctrl+w` puis `+`
- dé-zoom de la vue actuelle : `Ctrl+w` puis `-`
- égalise la taille des vues : `Ctrl+w` puis `=`
- échange la position des vues : `Ctrl+w` puis `r` (ou `R` pour le sens inverse)
- fermer la vue actuelle : `Ctrl+w` puis `q`
- Augmenter ou diminuer :
    * la hauteur d'une vue de 10 lignes : `Ctrl+w` puis `10` puis `+` ou `-`
    * la largeur d'une vue de 10 lignes : `Ctrl+w` puis `10` puis `>` ou `<`

## Tabs

Vim permet de gérer plusieurs tabs.

Pour ouvrir des fichiers dans plusieurs tabs :
```
$ vim -p file1 file2 file3
```

Dans vim :

- Pour ouvrir un fichier dans un nouveau tab : `:tabedit file_path`
- Pour fermer le tab courant : `:tabclose` (ou `Ctrl+w` puis `q`)
- Pour fermer tous les tabs sauf le courant : `:tabonly`
- Pour déplacer une vue vers un nouveau tab : `Ctrl+w` puis `T`

Navigation en mode normal :

- Pour passer au tab suivant : `gt`
- Pour passer au tab précédent : `gT`
- Pour aller au tab 2 (les indices commencent à 1) : `2gt`

## Autocomplétion

En mode édition :

- Aller à la suggestion suivante : `Ctrl+n`
- Aller à la suggestion précédente : `Ctrl+p`

## Commande externe

Pour lancer une commande externe dans *vim* : `:!commande`

## Édition hexadécimale

- Passer en mode d'édition hexadécimale : `:%!xxd`
- Revenir en édition normale : `:%!xxd -r`

## ctags

Installer d'abord `ctags` dans sa distribution.

### Génération des tags

Pour générer un fichier de tags, se placer dans le dossier des sources puis : `$ ctags -R *`.
Un fichier `tags` est alors généré dans le dossier courant.

### Dans vim

- Pour charger un fichier de tags particulier : `:set tags+=<path_tags_file>`
- Pour chercher, se placer sur un symbole puis `Ctrl+]`
- Pour revenir en arrière : `Ctrl+t`

## Plugins

### Surround

Assistance à la saisie des paires de caractères (ou des balises).

<https://github.com/tpope/vim-surround>

Il existe un paquet précompilé pour Arch :
```
# pacman -S vim-surround
```

### fzf

- <https://github.com/junegunn/fzf/>
- <https://github.com/junegunn/fzf.vim>

### Commentaires

On peut utiliser ce plugin : <https://github.com/preservim/nerdcommenter> 

Il y a un paquet précompilé sous Arch :
```
# pacman -S vim-nerdcommenter
```

> Par défaut, la *leader key* est `\`.

En mode interactif ou visuel :

- commenter ou décommenter une ligne : `[count]\c<space>`
- commenter le texte sélectionné : `[count]\cc`
- décommenter le texte sélectionné : `[count]\cu`

### Correction orthographique

- Activer la correction orthographique : `:set spell`
- Spécifier la langue : `:set spell spelllang=fr`
- Désactiver la correction orthographique : `set nospell`

> Note : Pour l'activation et désactivation du mode de correction, on peut mapper la touche `F6` en ajoutant cette ligne dans le fichier de configuration de *vim* :
```
map <silent> <F6> "<Esc>:silent setlocal spell! spelllang=fr<CR>"
```

Lors de la première utilisation, *vim* va tenter de télécharger les fichiers de langues nécessaires. S'il n'y parvient pas, on peut le faire manuellement :
```
$ cd $HOME/.vim/spell
$ wget http://ftp.vim.org/vim/runtime/spell/fr.latin1.spl
$ wget http://ftp.vim.org/vim/runtime/spell/fr.latin1.sug
$ wget http://ftp.vim.org/vim/runtime/spell/fr.utf-8.spl
$ wget http://ftp.vim.org/vim/runtime/spell/fr.utf-8.sug
```

### Barre de status

Pour avoir une belle barre de status  : <https://github.com/itchyny/lightline.vim>

### Arborescence des fichiers

Pour avoir un panneau avec l'arborescence des fichiers : <https://github.com/preservim/nerdtree>

Il existe un paquet précompilé sous Arch :
```
# pacman -S vim-nerdtree
```

On peut mapper une touche pour afficher/masquer le panneau : `map <C-o> :NERDTreeToggle<CR>` (à mettre dans le `.vimrc`).

### Autojump

<https://github.com/wting/autojump>

Permet de faciliter l'ouverture des fichiers. Il propose en priorité les fichiers ouverts le plus souvent.

### Thèmes
 
Suivre les indications. Par exemple : 

- <https://github.com/joshdick/onedark.vim>
- <https://github.com/altercation/vim-colors-solarized>
- <https://github.com/zefei/simple-dark>
- <https://github.com/sonph/onehalf/tree/master/vim>

## Sources

- https://openclassrooms.com/fr/courses/43538-reprenez-le-controle-a-laide-de-linux/42693-vim-lediteur-de-texte-du-programmeur
- https://doc.ubuntu-fr.org/vim
- https://www.saintcarre.fr/saintcarre/2018/08/correcteur-orthographe-vim.html
- https://www.shortcutfoo.com/blog/top-50-vim-configuration-options/
- https://vim.fandom.com/wiki/Using_tab_pages
- https://vimawesome.com/
