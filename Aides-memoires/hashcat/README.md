# hashcat

## Utilisation avec un GPU

On suppose ici qu'on a une installation de *hashcat* qu'on va utiliser avec
un GPU *nvidia* (avec le framework *CUDA*).

Sous Linux, les drivers nvidia sont installés avec *bumblebee*. Il faut
ajouter `optirun` avant toutes commandes lorsqu'on veut utiliser le GPU.

Pour voir les backends de calculs disponibles :
```
optirun hashcat -I
```

## Généralités

Pour lancer un calcul :
```
optirun hashcat -m 1000 \
                -a 0 \
                -d 1,2,3 \
                --session <session_name> \
                <hash_file_path> \
                <wordlist_path> \
                -r <rulesfile_path> \
                -O
```

- `-m` : le type de hash à cracker
- `-a` : le mode d'attaque (par exemple : 0 pour Straight, 3 pour Bruteforce)
- `-d` : les devices de calcul à utiliser (utiliser `-I` pour les lister)
         On peut aussi utiliser `-D` pour spécifier les **types** de devices
         à utiliser (1: CPU, 2: GPU, ...).
- `--session` : pour nommer la session actuelle et pouvoir la restaurer
                si elle s'arrête (création d'un fichier `.restore` dans
                `~/.hashcat/sessions/`).
- `-r` : fichier de règles de dérivation des mots
- `-O`: active les *optimisations du kernel*... ça va plus vite mais ça limite 
  la taille des mots de passe en entrée

Pour le mettre en pause proprement, choisir *Checkpoint* en appuyant sur `c`.
Cela arrêtera l'opération après la prochaine écriture dans le fichier
`.restore`. Si on quitte avec `q` ou que l'opération s'arrête brutalement,
on pourra quand même restaurer la session (les mots de passe passés depuis
le dernier checkpoint devront juste être retestés).

Pour relancer une session existante :
```
optirun hashcat --session <session_name> --restore
```

> Si on ne met pas `--session`, le fichier de session est enregistré
  par defaut dans le fichier `~/.hashcat/sessions/hashcat.restore`.
  Dans ce cas, pas besoin de spécifier `--session` pour restaurer la session.

Pour redéfinir la température d'alerte pour le GPU (ici à 97°C) :
`--hwmon-temp-abort=97`

## Bruteforce

Les attaques par bruteforce se font à l'aide du mode `-a 3`.

Les charsets prédéfinis :

- ?l = `abcdefghijklmnopqrstuvwxyz`
- ?u = `ABCDEFGHIJKLMNOPQRSTUVWXYZ`
- ?d = `0123456789`
- ?h = `0123456789abcdef`
- ?H = `0123456789ABCDEF`
- ?s = ``«space»!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~``
- ?a = `?l?u?d?s`
- ?b = `0x00 - 0xff`

On peut définir des *sous-charsets* avec `-1`, `-2`, `-3` et `-4`.
On doit ensuite fournir le *mask* à utiliser. Il définit la longueur et le
charset (ou *sous-charset*) pour chaque caractère).

Exemples :

- 4 caractères parmi les chiffres (pas besoin de `-1` ici) :
  `-a 3 <hash_file> ?d?d?d?d`
- 8 caractères parmi chiffres et lettres majuscules et minuscules :
 `-a 3 <hash_file> -1 ?d?l?u ?1?1?1?1?1?1?1?1`

> Pour tester aussi les clés plus petites que le *mask* spécifié, on peut
  ajouter l'option `--increment`.

## Clé WPA/WPA2

```
optirun hashcat -m 2500 capture.hccapx rockyou.txt
```
## Création d'un dictionnaire à partir de rules

Ca peut aller plus vite de ne pas utiliser les rules (`-r`) pendant les calculs et de lancer les calculs 
seulement avec le dictionnaire. Dans ce cas, il faut faire le dictionnaire dérivé en amont 
en utilisant les rules :
```
hashcat --force <wordlist.lst> -r <rule_file> --stdout > wordlist_derivated.lst
```

## Sources

- <https://hashcat.net/wiki/>
- <https://hashcat.net/wiki/doku.php?id=cracking_wpawpa2>
