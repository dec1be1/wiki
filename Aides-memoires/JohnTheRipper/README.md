John The Ripper
===============

# Modes
Trois modes sont possibles.

## Single
```
# john --single [HASH_FILE]
```
John va tester des combinaisons de caractères basées sur les logins à tester et sur les règles données dans le fichier de configuration `/etc/john/john.conf`.

On peut ajouter des mots à l'analyse dans la section `[List.Single.SeedWords]`.

Ce mode est généralement rapide.

## Wordlist
Le principe est ici de tester tous les mots d'une liste.
```
# john --wordlist /root/wordlists/rockyou.txt [HASH_FILE]
```

Si aucune liste n'est spécifiée, john utilise par défaut sa propre liste. Le temps est proportionnel à la longueur de la liste.

## Incremental
Ce mode teste toutes les combinaisons de caractères d'un jeu donné. Il peut être très (trop) long !
```
# john --incremental [HASH_FILE]
```

# unshadow
Lorsqu'on dispose, sous GNU/Linux, des fichiers `/etc/passwd` et `/etc/shadow`, il faut d'abord les combiner pour pouvoir les utiliser avec john. On utilise l'utilitaire `unshadow` :
```
# unshadow /etc/passwd /etc/shadow > ./unshadow
```
On peut alors lancer john sur ce fichier :
```
# john ./unshadow
```

# Formats de hash
On peut spécifier le type de hash pour aider john. Par exemple :
```
# john --format=sha512crypt [HASH_FILE]
```

# Mots de passe déjà crackés
Pour visualiser les mots de passe que john a réussi à cracker sur un fichier particulier :
```
# john --show [HASH_FILE]
```

# Sources
* https://www.openwall.com/john/doc/
* https://artduweb.com/tutoriels/jtr
