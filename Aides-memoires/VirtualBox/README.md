# VirtualBox

## Compactage image disque VDI

### Préparation du *guest*

Sur le *guest*, mettre à zéro les secteurs des fichiers non alloués.
La procédure pour faire ça dépend du système d'exploitation.

#### GNU/Linux

Exemple pour `/dev/sda1` :

- Il faut que la partition cible soit montée en mode *read-only*.
  Le plus simple est de monter cette partition dans une autre machine
  virtuelle et de faire les opérations suivantes depuis cette autre VM.
  Ou alors modifier le `/etc/fstab` (ajouter l'option `ro`) et redémarrer
  en mode *maintenance* sans oublier de rétablir l'état initial après.
- Une fois que la partition cible est montée en *ro*
  (`mount -o remount,ro /dev/sda1` si nécessaire), lancer :
  `zerofree -v /dev/sda1`

#### Windows

Exemple pour `C:\` :

- Si ça n'a pas été fait depuis longtemps, défragmenter le disque
- Lancer (avec droits administrateur) : `sdelete.exe c:\ -z`

#### MacOS

- Lancer (avec les droits administrateur) : `diskutil secureErase freespace 0`

### Réduction de l'image du disque

Ca se passe maintenant sur l'*host*. On éteint la VM concernée puis :
```
VBoxManage modifyhd disk.vdi --compact
```

Source : <https://gist.github.com/kuznero/576e848c39080745ac1915c6b3e4820b>
