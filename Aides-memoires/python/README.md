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
