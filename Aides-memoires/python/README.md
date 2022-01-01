Python
======

## pip

Pour voir les modules à mettre à jour :
```
pip list --outdated
```

Pour mettre à jour tous les modules :
```
pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U --user
```

Pour vérifier ensuite :
```
pip check
```

## subprocess

Pour lancer un processus en lisant sur *stdin* puis imprimer le résultat (même
si c'est sur *stderr*) et le code de retour :
```python
import subprocess
import shlex
args = shlex.split(command)
p = subprocess.run(args, input=input_string.encode(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
print(p.stdout.decode())
print(p.returncode)
```

## format

La spécification du type de données à afficher à l'aide de la fonction
`format()` peut se faire avec la syntaxe suivante :
`{numéro_argument:conversion}`, avec `conversion` pouvant prendre les valeurs
suivantes :

- `s` : strings
- `d` : decimal integers (base-10)
- `f` : floating point display
- `c` : character
- `b` : binary
- `o` : octal
- `x` : hexadecimal with lowercase letters after 9
- `X` : hexadecimal with uppercase letters after 9
- `e` : exponent notation

Comme en C, on peut ajouter, avant le code précédent, le nombre de caractères
à afficher (avec padding en ajoutant encore un zéro devant).
Par exemple : `{0:08x}` sera bien adapté pour afficher une adresse mémoire sur
32 bits.

Source : <https://www.geeksforgeeks.org/python-format-function/>
