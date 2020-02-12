Python
======

# pip / pip3
Pour mettre à jour tous les modules :
```
$ pip install -r <(pip freeze) --upgrade
```

Pour pip3, ajouter un 3.

Pour vérifier ensuite :
```
$ pip check && pip3 check
```

# subprocess
Pour lancer un processus en lisant sur *stdin* puis imprimer le résultat :
```python
import subprocess
p = subprocess.run(command, input=input_string.encode(), stdout=subprocess.PIPE)
print(p.stdout.decode())
```

# format
La spécification du type de données à afficher à l'aide de la fonction `format()` peut se faire avec la syntaxe suivante : `{numéro_argument:conversion}`, avec `conversion` pouvant prendre les valeurs suivantes :
- `s` : strings
- `d` : decimal integers (base-10)
- `f` : floating point display
- `c` : character
- `b` : binary
- `o` : octal
- `x` : hexadecimal with lowercase letters after 9
- `X` : hexadecimal with uppercase letters after 9
- `e` : exponent notation

Comme en C, on peut ajouter, avant le code précédent, le nombre de caractères à afficher (avec padding en ajoutant encore un zéro devant).
Par exemple : `{0:08x}` sera bien adapté pour afficher une adresse mémoire sur 32 bits.

*Source :* <https://www.geeksforgeeks.org/python-format-function/>
