gdb
===

## Configuration
### Syntaxe
Pour utiliser la syntaxe *Intel*, taper dans `gdb` :
```
(gdb) set disassembly-flavor intel
```
Pour éviter d'avoir à le retaper à chaque démarrage de `gdb`, éditer le ficher `~/.gdbinit` :
```
$ echo "set disassembly-flavor intel" > ~/.gdbinit
```

### Processus
Par défaut, c'est le *parent process* qui est suivi par `gdb`. Pour suivre le *child process* (dans le cas de l'étude d'un *daemon* par exemple) :
```
(gdb) set follow-fork-mode child
```

## Rappels syntaxe assembleur Intel
Une instruction dans la syntaxe assembleur *Intel* est généralement de la forme :
```
instruction <destination>, <source>
```
Quelques instructions :
* `mov` : déplace une valeur de la source vers la destination.
* `sub` : soustrait la source à la destination (le résultat est stocké dans la destination).
* `inc` : similaire à `sub` mais incrémente au lieu de soustraire.
* `cmp` : compare les valeurs destination et source et ajuste les flags selon le résultat.
* `jle` : se réfère au résultat d'une instruction `cmp` juste avant. Saute à l'adresse indiquée après le `jle` si la valeur destination est inférieure ou égale à la valeur source. C'est l'abréviation de *Jump if Less than or Equal to*.
* `jmp` : saute à l'adresse indiquée en argument (modifie le registre *eip*).
* `call` : empile le contenu de *eip* et saute à l'adresse de la fonction appelée (équivaut à `push EIP` puis `jmp adresse_fonction`).
* `lea` : charge l'adresse de la source dans destination. C'est l'abréviation de *Load Effective Address*.

## Rappels sur les registres
Pour processeurs 32 bits :

| Registre | Traduction | Description |
|----------|------------|-------------|
| eax, ebx, ecx, edx | data registers| Registres généraux pour stocker des données |
| esp | stack pointer | Contient l'adresse du haut de la pile |
| ebp | base pointer ou frame pointer | Adresse de la stackframe courante (permet de référencer les variables de la fonction dans la stackframe courante) |
| esi | source index | Registre d'index source |
| edi | destination index | Registre d'index destination |
| eip | instruction pointer | Contient l'adresse de l'instruction courante |
| sfp | save frame pointer | Contient l'adresse du stackframe du contexte précédent (permet de sauver ebp puis de le restaurer à sa valeur précédente) |

Pour les processeurs 64 bits, on remplace le *e* (extended) par un *r* (re-extended).

## Démarrage
Pour lancer `gdb` sans la bannière de démarrage :
```
$ gdb -q [executable_file]
```

## Commandes
### list
Permet de lister le code source (par bloc de 10 lignes). On peut également ne lister qu'une partie du code :
* une fonction particulière en ajoutant son nom en argument (par exemple : `(gdb) list main`).
* à partir d'un numéro de ligne en l'indiquant en argument (par exemple : `(gdb) list 1`).
* ... voir l'aide pour plus : `(gdb) help list`

Cette commande fonctionne à la condition que le programme ait été compilé avec l'option -g (`gcc -g ...`).

### disass
Affiche le code assembleur. On peut indiquer la fonction à traiter en argument. Exemple :
```
(gdb) disass main
```

### info
Pour obtenir des informations sur un registre processeur :
```
(gdb) info register nom_registre
```
ou
```
(gdb) i r nom_registre
```

Exemple pour le registre `eip` :
```
(gdb) i r eip
```

Pour voir tous les registres d'un coup :
```
(gdb) info registers
```

Pour voir les infos sur le stackframe courant :
```
(gdb) info frame
```
ou
```
(gdb) i f
```

### examine
`examine` (ou `x` en abrégé) permet d'examiner le contenu de la mémoire.
```
(gdb) x/NFT adresse
```
* N : nombre d'item à afficher
* F : format d'affichage
* T : type d'item à afficher

#### Format d'affichage
* x : hexadécimal
* z : hexadécimal (complété avec des zéros sur la gauche)
* o : octal
* d : décimal
* u : entier non signé base 10 (unsigned)
* f : flottant
* t : binaire
* s : chaîne de caractères
* c : caractère
* i : instruction
* a : adresse

#### Type d'item
* b :  single byte (8 bits / 1 octet)
* h : half word (16 bits / 2 octets)
* w : word (32 bits / 4 octets)
* g : giant word (64 bits / 8 octets)

#### Exemples
Afficher 12 octets au format hexadécimal à partir du registre *eip* :
```
(gdb) x/12xb $eip
```

Afficher 4 entiers non signés au format décimal à partir de l'adresse *0x8048384* :
```
(gdb) x/4uw 0x8048384
```

### print
`print` (`p` en abrégé) permet d'afficher diverses informations (variables, ...). Permet aussi des conversions décimales/hexadécimales.

Pour convertir 31337 en hexadécimal :
```
(gdb) p /x 31337
```

Pour convertir une valeur hexadécimale en décimal :
```
(gdb) p 0x4f0a
```

### run / continue
`run` permet de lancer l'exécution du programme. Si le programme admet des arguments, ils peuvent être spécifiés après le `run`.

`continue` (ou `cont` en abrégé ou `c` en super abrégé) permet de reprendre l'exécution du programme après un point d'arrêt (`breakpoint`).

### breakpoint
`breakpoint` (ou `break` en abrégé ou `b` en super abrégé) permet de spécifier des points d'arrêts pendant l'exécution du programme. La mémoire et les registres pourront être examinés lors de ces points d'arrêt. On peut déclarer autant de points d'arrêt que nécessaire. Le numéro de la ligne est à spécifier. Par exemple :
```
(gdb) breakpoint 14
```

On peut également faire un *breakpoint* au niveau d'une fonction ou à `x` lignes après. Par exemple, pour déclarer un breakpoint 4 lignes après la fonction `main` :
```
(gdb) break *main + 4
```

Ou directement une adresse en mémoire :
```
(gdb) break *0x080484ce
```

### backtrace
La commande `backtrace` (`bt` en abrégé) permet d'afficher la backtrace du stack. Utile pour trouver une adresse de retour par exemple.
```
(gdb) bt
```

### stepi
`stepi` (ou `si` en abrégé) permet de sauter à l'instruction suivante (au moment d'un *breakpoint*). Si un entier `N` est fourni en argument, on saute de N instructions.
