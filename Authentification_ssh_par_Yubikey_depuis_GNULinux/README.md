# Authentification ssh par Yubikey depuis un poste GNU/Linux

Ce wiki décrit la procédure à suivre pour ouvrir une session ssh à un serveur
distant depuis un poste GNU/Linux en utilisant une clé gpg stockée sur une
smartcard (une *Yubikey* en l’occurrence).

La Yubikey doit être correctement configurée. Les clés gpg doivent avoir été
importées. On va utiliser la sous-clé A (*Authentication*).
Voir [Sources](##Sources) pour faire ça.

La clé publique correspondante doit évidemment être présente dans le fichier
`authorized_keys` du serveur auquel on veut se connecter.

## Installation

* Installer le démon *SmartCard* (et d'autres paquets) et *GnuPG* si ça n'est
  pas déjà fait (le paquet `gpg-agent` doit également être installé).
  Pour *Debian* :
```
sudo apt install scdaemon pcscd ykcs11 pinentry-tty gnupg2
```
* Ajouter la ligne `enable-ssh-support` au fichier `~/.gnupg/gpg-agent.conf` :
```
echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
```
* Créer le fichier `/etc/udev/rules.d/70-yubikey.rules` avec le contenu
  suivant (remplacer `amnesia` par le nom du user) :
```
ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", OWNER="amnesia", TAG+="uaccess"
```
* Taper la commande suivante pour prendre en compte ce fichier :
```
sudo udevadm control --reload-rules
```
* Si on veut toujours utiliser la *Yubikey* comme moyen d'authentification, on
  peut ajouter ce qui suit à son fichier `~/.bashrc` :
```
pgrep -l gpg-agent &>/dev/null
if [[ "$?" != "0" ]]; then
    gpg-agent --daemon &>/dev/null
fi
export SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"
```
Le principe est que l'on démarre l'agent gpg s'il n'est pas en fonctionnement
puis on ré-écrit le socket d'authentification ssh pour qu'il utilise
`gpg-agent`.

## Utilisation

* Si le fichier `~/.bashrc` a été modifié comme indiqué plus haut, rien de
  plus à faire. On peut se connecter en ssh et entrer le code PIN quand il est
  demandé. Sinon, pour une utilisation ponctuelle, le plus simple est de créer
  [ce fichier](./yubikey.sh) et de le sourcer dans un shell lorsque
  nécessaire :
`$ source ./yubikey.sh`.
* On peut vérifier que l'identité est bien chargée dans l'agent ssh :
```
ssh-add -l
```
* On peut voir les informations de la *Yubikey* grâce à *gpg* :
```
gpg --card-status
```

## Sources

* https://gist.github.com/ageis/14adc308087859e199912b4c79c4aaa4
* https://www.ultrabug.fr/hardening-ssh-authentication-using-yubikey-32/
