# Langage C

## Les segments mémoire

| Low addresses |
|:-------------:|
|...|

| Segment | Description | Caractéristiques |
|---------|-------------|------------------|
|text | Contient le code compilé. | Taille fixe et protégé en écriture. |
|data | Contient les variables statiques et globales initialisées dans le code. | Taille fixe. Les variables stockées dans ce segment persistent quel que soit le contexte fonctionnel. |
|bss | Contient les autres variables (non initialisées). | Taille fixe. |
|heap | Zone mémoire utilisable par le programmeur : `malloc()`. | Taille variable pendant l'exécution du programme. |
|stack | Pile : contient les stackframes empilées. | Taille variable. Zone de mémoire temporaire permettant de stocker les variables locales et le contexte des fonctions lors de leur appel. Structure de données de type FILO (*First In Last Out*). Les données sont empilées dans le stack vers les adresses basses (vers le haut de ce tableau).|

| High addresses |
|:-------------:|
|...|


## gcc

Pour compiler le programme `code.c`. Le résultat est le fichier `executable` :
```
gcc -o executable code.c
```

Quelques options utiles :

* `-o` : spécifie le fichier cible.
* `-Wall` : affiche tous les ''warnings''.
* `-g` : compile en incluant des flags utiles au débogage (code source).
* `-m32` : compile un binaire 32 bits sur une machine 64 bits.
* `-fno-stack-protector` : désactive la protection du stack
  (SSP : *Stack Smashing Protection*).
* `-z execstack` : rend le stack exécutable.
* `-D_FORTIFY_SOURCE=0` : force la désactivation du remplacement des
  fonctions non-sécurisées (strcpy, ...).
* `-z norelro` : force la désactivation de la protection *relro*
  (*RELocation Read-Only*).

## ASLR

L'ASLR (*Address Space Layout Randomization*) est un procédé qui rend
aléatoire l'adressage en mémoire. Cette technique rend plus difficile
l'exploitation de failles de type *buffer overflow*.

Pour voir si l'ASLR est activé ou pas sous GNU/Linux :
```
cat /proc/sys/kernel/randomize_va_space
```

On peut l'activer :
```
echo "2" | sudo dd of=/proc/sys/kernel/randomize_va_space
```

Ou le désactiver :
```
echo "0" | sudo dd of=/proc/sys/kernel/randomize_va_space
```

## Fonction `printf()`

### Formats de chaînes de caractères (Format Strings)

#### Formats de paramètre acceptant des valeurs

`printf` attend une valeur et affiche le résultat sous la forme :

* `%d` : décimal
* `%c` : caractère
* `%u` : décimal non signé
* `%x` : hexadécimal

#### Formats de paramètre acceptant des pointeurs

`printf` attend un pointeur (une adresse en mémoire) et affiche le résultat
sous la forme :

* `%p` : adresse au format hexadécimal
* `%s` : string
* `%n` : nombre d'octets écrits par `printf` jusqu'au paramètre `%n` dans la
  format string. Ce format de paramètre écrit le nombre d'octets à l'adresse
  indiquée en paramètre (au lieu de lire et afficher comme les autres formats
  de paramètre).

On peut mettre un nombre décimal entre le `%` et la lettre pour spécifier le
nombre de caractères à afficher (*field width*). Si le *field width* commence
par un zéro (par exemple `%08x`), la valeur affichée est complétée par des
zéros (*0-padded*) au lieu de l'être par des espaces.

### Syntaxe

```
printf(Chaîne contenant les valeurs et pointeurs à afficher, valeur, valeur, pointeur, ...);
```

### Exemples

Pour afficher une chaîne de caractères et son adresse en mémoire (avec un
*field width* de 8) :
```
printf(Address of %s: %08x, string, string);
```

## Incrémentation pré et post-fixée

| Instruction | Description |
|-------------|-------------|
|x=i++ | Copie la valeur de i dans x **puis** incrémente i |
|x=i-- | Copie la valeur de i dans x **puis** décrémente i |
|x=++i | Incrémente i **puis** copie la valeur de i dans x |
|x=--i | Décrémente i **puis** copie la valeur de i dans x |
