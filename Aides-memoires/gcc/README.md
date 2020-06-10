gcc
===

## Compilation séparée
Pour compiler une librairie `.c` (un fichier objet `.o` est créé) :
```
$ gcc -o mylib.o -c mylib.c
```

Ne pas oublier d'inclure les prototypes dans un fichier d'entêtes `mylib.h`. Inclure la ligne `#include "mylib.h"` dans tous les fichiers utilisant les fonctions de `mylib.c` (par exemple le fichier source principal `main.c`).

Pour compiler le programme principal et le lier avec le fichier objet de la librairie :  
```
gcc -o main main.c mylib.o
```


## Sources
* https://www.cs.swarthmore.edu/~newhall/unixhelp/howto_C_libraries.html
