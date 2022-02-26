# Installation support U2F (Yubikey) sur Debian

Cet article décrit la procédure pour installer le support *U2F*
(Yubikey par exemple) sur un système Debian. Cela doit fonctionner sur la
plupart des distributions GNU/Linux.

## Installation du support U2F

* Ajouter le fichier suivant :
  [70-u2f.rules](https://github.com/Yubico/libu2f-host/blob/master/70-u2f.rules)
  dans le dossier `/etc/udev/rules.d/``
* Ajuster les droits si nécessaire :
```
sudo chown root:root /etc/udev/rules.d/70-u2f.rules && chmod 644 /etc/udev/rules.d/70-u2f.rules
```
* Taper la commande suivante pour prendre en compte ce fichier :
```
sudo udevadm control --reload-rules
```

## Activation du support dans Firefox

Le support *U2F* n'est pas activé par défaut sous *Firefox*.

* Aller sur la page de configuration : taper `about:config` dans la barre
  d'adresse.
* Chercher la clé *security.webauth.u2f* et la passer à *true*.

## Sources

* <https://support.yubico.com/support/solutions/articles/15000006449-using-your-u2f-yubikey-with-linux>
