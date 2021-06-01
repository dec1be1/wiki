GPG
===

Quelques commandes utiles pour *GPG*.

## Opérations sur les clés

### Création d'une paire de clés

Taper la commande suivante et se laisser guider :
```
$ gpg --full-gen-key
```

Pour créer un certificat de révocation :
```
$ gpg --output revoke.asc --gen-revoke <id_clé>
```

Pour révoquer la clé :
```
$ gpg --import revoke.asc
```

### Gestion du trousseau de clés

Pour exporter une clé publique :
```
$ gpg --output pk.asc --armor --export <id_clé>
```

Pour exporter une clé privée (**attention... elle doit rester secrète !**) :
```
$ gpg --output sk.asc --armor --export-secret-key <id_clé>
```

Pour exporter les sous-clés privées
(**attention... elles doivent rester secrètes !**) :
```
$ gpg --output subsk.asc --armor --export-secret-subkeys <id_clé>
```

Pour importer une clé publique dans le trousseau (si le nom du fichier n'est
pas spécifié, l'import se fait depuis le presse-papier) :
```
$ gpg --import pk.asc
```

Pour lister toutes les clés publiques du trousseau :
```
$ gpg --list-keys
```

Pour lister toutes les signatures des clés publiques du trousseau :
```
$ gpg --list-sigs
```

Pour lister toutes les clés privées du trousseau :
```
$ gpg --list-secret-keys
```

Pour pousser une clé publique sur un serveur de clés :
```
$ gpg --keyserver hkp://pgp.mit.edu --send-key <id_clé>
```

Pour chercher une clé publique sur un serveur (si le serveur n'est pas
indiqué, celui par défaut est pris en compte : `hkp://keys.gnupg.net`) :
```
$ gpg --search-keys <id_clé>
```

Importer une clé publique depuis un serveur de clés :
```
$ gpg --recv-keys <id_clé>
```

Pour supprimer une clé publique de son trousseau :
```
$ gpg --delete-keys <id_clé>
```

Pour supprimer une clé privée de son trousseau :
```
$ gpg --delete-secret-key <id_clé>
```

Pour éditer une clé (on se retrouver avec un prompt `gpg`) :
```
$ gpg --edit-key <id_clé>
```

Pour voir l'empreinte une clé (mettre `--fingerprint` deux fois pour avoir
plus d'informations) :
```
$ gpg --fingerprint <id_clé>
```

Pour signer une clé publique (également possible depuis le prompt obtenu
avec `--edit-key` :
```
$ gpg --sign-key <id_clé>
```

## Opérations sur les fichiers

### Chiffrement et signature

Pour chiffrer un fichier avec l'identité donnée (génère un fichier `.gpg`) :
```
$ gpg --recipient <id_clé_destinataire> --encrypt <file>
```

Pour générer une signature dans un fichier séparé (dans un fichier `.sig`) :
```
$ gpg -sb <file>
```

### Déchiffrement et vérification

Pour vérifier la signature (le fichier de données doit être dans le même
dossier) :
```
$ gpg --verifiy <file.sig>
```

Pour déchiffrer le fichier :
```
$ gpg --output <file> --decrypt <file.gpg>
```

## Smartcards

Pour éditer les informations de la carte à puce :
```
$ gpg --card-edit
```

Pour voir les informations de la carte à puce :
```
$ gpg --card-status
```

## Bonnes pratiques

Il est conseillé (tout cela n'engage que moi... je vous invite à vous
renseigner de votre côté sur les bonnes pratiques cryptographiques !) de
conserver la clé privée primaire hors connexion (sur un support amovible
chiffré par exemple). Pour cela, il faut créer a minima une sous-clé pour la
signature (S). Normalement, une sous-clé pour le chiffrement (E) est créée au
moment de la génération des clés. On peut aussi créer une sous-clé pour
l'authentification (A) qui peut servir par exemple à se connecter en ssh à un
serveur.
L'inconvénient à ça est que lorsqu'on veut signer la clé publique de
quelqu'un ou modifier les paramètres de sa propre clé (ajout identités, ...),
il faut monter le support amovible pour accéder à sa clé privée primaire qui
est alors nécessaire. Cela dit, au quotidien, il me semble que ce n'est pas
trop contraignant par rapport au gain en sécurité.

Donc, dans l'ordre :

* Génération d'une paire de clés (une sous-clé pour le chiffrement est
  normalement créée) sur une machine sûre
* Création d'une sous-clé pour la signature (et d'une sous-clé pour
  l'authentification (A) si nécessaire)
* Export de la clé privée primaire et des sous-clés
* Déplacement de la clé privée primaire sur un support amovible sûr
* Suppression de la clé privée primaire du trousseau *gpg* (en général
  les sous-clés sont supprimées aussi)
* Import des sous-clés dans le trousseau *gpg*

Encore mieux lors de la création des clés : les créer directement sur le
support amovible sûr puis importer uniquement les sous-clés et la clé publique
dans votre trousseau *gpg*.

Lorsqu'on a besoin de sa clé privée primaire (pour signer la clé publique de
quelqu'un ou faire des opération sur ses propres clés), il faut récupérer le
support amovible, importer la clé privée primaire puis la supprimer quand on a
terminé. Une alternative beaucoup plus pratique est de mettre cette clé maître
dans une *smartcard* (*yubikey* par exemple).

## Sources

* <https://www.gnupg.org/documentation/howtos.html>
* <http://wiki.csnu.org/index.php/GnuPG_:_Cr%C3%A9er_la_paire_de_cl%C3%A9_gpg_parfaite_:_cl%C3%A9_maitre,_subkeys_et_support_smartcard_(yubikey)>
* <https://openclassrooms.com/fr/courses/1112771-la-cryptographie-facile-avec-pgp>
* <https://gist.github.com/ageis/14adc308087859e199912b4c79c4aaa4>
* <https://linuxfr.org/users/gouttegd/journaux/de-la-gestion-des-clefs-openpgp>
