John The Ripper
===============

# Modes
Trois modes sont possibles.

## Single
```
# john --single [HASH_FILE]
```
John va tester des combinaisons de caractères basées sur les logins identifiés et sur les règles données dans le fichier de configuration `/etc/john/john.conf`.

On peut ajouter des mots à l'analyse dans la section `[List.Single.SeedWords]`.

Ce mode est généralement rapide.

## Wordlist
Le principe est ici de tester tous les mots d'une liste.
```
# john --wordlist=/root/wordlists/rockyou.txt [HASH_FILE]
```

Si aucune liste n'est spécifiée, john utilise par défaut sa propre liste. Le temps est proportionnel à la longueur de la liste.

On peut ajouter `--rules` pour activer les règles de mangling. Dans ce cas, lorsque john teste un mot, il teste également différentes variations de ce mot selon les règles définies.

On peut également préciser le type d'encodage de la wordlist avec l'option `--encoding=[...]`. Par exemple `--encoding=ASCII`. C'est utile lorsque john n'identifie pas bien le type d'encodage d'un fichier.

## Incremental
Ce mode teste toutes les combinaisons de caractères d'un jeu donné (cf. fichier de configuration de john). Il peut être très (trop) long !
```
# john --incremental [HASH_FILE]
```

# Mangling rules
Les *mangling rules* permettent de faire des dérivations de mots selon des règles établies dans le fichier de configuration de john.
On peut les activer avec l'option `--rules`. On peut spécifier un jeu de règles particuliers. Par exemple `--rules=Jumbo` qui est un jeu présent par défaut.
Voir les jeux de règles existants dans le fichier de configuration.
A noter qu'il existe des utilitaires permettant de générer des fichiers de configuration avec des jeux de règles entièrement paramétrables.

On peut également générer un dictionnaire custom utilisant des *mangling rules* avec l'option `--stdout`. Cela permet d'utiliser ce dictionnaire avec un autre logiciel. Par exemple :
```
# john --config=custom_config_file --wordlist=custom_wordlist.txt --rules=Jumbo --stdout
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

# Fichiers zip ou rar
Pour cracker un fichier zip ou rar protégé, il faut d'abord créer le fichier de hash en utilisant l'utilitaire `zip2john` :
```
# zip2john fichier.zip > fichier.hash
```
Pour les fichiers rar, utiliser `rar2john`.

On peut ensuite utiliser john normalement avec ce fichier de hash.

# Clés privées RSA
**Il n'est pas question ici de trouver une clé privée RSA en connaissant la clé publique.**

On veut ici trouver la *passphrase* d'une clé privée RSA chiffrée de manière à la déchiffrer. On va procéder exactement de la même manière que pour les fichiers zip ou rar mais en utilisant un script python pour créer le fichier de hash : https://github.com/koboi137/john/blob/master/ssh2john.py.

On utilise ensuite john normalement avec le fichier de hash créé. On peut évidemment mettre plusieurs clés privées dans le fichier de hash.

# Crack de mot de passe avec sel
## Préambule
On commence par créer le fichier de hash selon ce format :
```
# echo "username:hash$salt" > hash.txt
```
Pour lister les sous-formats disponibles :
```
# john --list=subformats
```

## Exemple pour md5(salt+password)
On dispose du salt et du hash md5(salt+password). On veut trouver le password.

On voit en listant les sous-formats qu'il s'agit du format `dynamic_4`. On lance john après avoir préparé le fichier de hash (cf. un peu plus haut) :
```
# john --format=dynamic_4 ./hash.txt
```

On peut utiliser toutes les options habituelles.

# Sources
* https://www.openwall.com/john/doc/
* https://artduweb.com/tutoriels/jtr
