# Authentification ssh par Yubikey sur un poste Windows

Ce wiki décrit la procédure à suivre pour ouvrir une session ssh à un serveur
distant depuis un poste Windows en utilisant une clé gpg stockée sur une
smartcard (une *Yubikey* en l’occurrence). J'ai ressenti le besoin d'écrire
cet article car le comportement de Windows pendant mes tests m'a parfois paru
incohérent. Aussi, quand j'ai trouvé la façon de faire qui fonctionne, je me
suis dit qu'il serait prudent de conserver tout ça.

La Yubikey doit être correctement configurée. Les clés gpg doivent avoir été
importées. On va utiliser la sous-clé A (*Authentication*).

Voir ces deux articles pour faire ça (sous GNU/Linux) :

* https://gist.github.com/ageis/14adc308087859e199912b4c79c4aaa4
* https://www.ultrabug.fr/hardening-ssh-authentication-using-yubikey-32/

La clé publique correspondante doit évidemment être présente dans le fichier
`authorized_keys` du serveur auquel on veut se connecter.

Enfin, il est possible qu'il faille désactiver certains drivers Windows
(par exemple : *NXP's ProximityBased SmartCard Reader* dans la section
*Lecteurs de cartes à puce* du gestionnaire de périphériques Windows). Cela
peut générer des conflits avec l'agent gpg. Attention, après certaines mises
à jour Windows, les drivers déactivés manuellement peuvent être réactivés.

## Installation

* Installer [GPG4Win](https://www.gpg4win.org/) (au moins *GnuPG*).
  Normalement l'agent gpg est installé et lancé par défaut au démarrage de
  Windows. S'il ne se lance pas automatiquement, on peut créer un lien avec ce
  chemin à l'intérieur (le chemin peut varier selon les systèmes... à vérifier
  avant donc) :
```
C:\Program Files (x86)\GnuPG\gpg-connect-agent.exe
```
* Créer le fichier `%APPDATA%\gnupg\gpg-agent.conf` et coller la ligne
  suivante dedans :
```
enable-putty-support
```
* L'agent gpg doit être redémarré pour que cette modification prenne effet
  (cf. [En cas de problèmes](##En cas de problèmes)).
* Installer le client ssh [PuTTY](https://www.putty.org/) (ainsi que l'agent
  ssh `pageant.exe`).

## Utilisation

* Insérer la Yubikey.
* Lancer depuis une console Windows depuis le répertoire d'installation de
  PuTTY et pageant les commandes du script suivant. Autant créer le script
  suivant et l'exécuter au besoin : [yubikey.bat](./yubikey.bat)
* Se connecter normalement grâce à PuTTY (vérifier dans les options de la
  connexion que l'authentification par l'agent ssh sera tentée).
* Entrer le PIN de la Yubikey lorsqu'il est demandé.
* Normalement, la session est enfin ouverte !

Remarques :

1. La commande `gpg --card-status` permet de faire un premier accès (après
   le démarrage de Windows) à la Yubikey. Cela semble indispensable pour que
   l'agent ssh (*pageant*) reconnaisse la clé.
2. La deuxième ligne n'est pas obligatoire. On pourrait lancer PuTTY
   directement depuis l'icône mais ça fait gagner un clic.

## En cas de problèmes

En cas de problèmes, les actions suivantes peuvent être tentées :

* Vérifier si la smartcard est reconnue par Windows (avec *Kleopatra* ou
  en exécutant la commande `gpg --card-status` par exemple).
* Redémarrer l'agent gpg (il est parfois un peu capricieux). Pour ça, taper
  les deux lignes suivantes dans une console Windows :
```
gpg-connect-agent killagent /bye
gpg-connect-agent /bye
```
* Revérifier si la smartcard est reconnue.
* Redémarrer Windows... ;D

## Sources

* https://developers.yubico.com/PGP/SSH_authentication/Windows.html
