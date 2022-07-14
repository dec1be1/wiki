# Parallels

## Parallels Tools

### Patch du module sous Linux

Il peut être nécessaire de patcher le module kernel de Parallels Tools sous
Linux après une mise à jour du kernel. C'est curieux pour un produit
commercial mais c'est comme ça ! :-/

L'échec de la compilation du module peut se traduire par
l'erreur suivante :
```
modprobe: FATAL: Module prl_tg not found in directory /lib/modules/...
```

Le patch se trouve généralement sur le forum de Parallels, dans cette section :
<https://forum.parallels.com/forums/linux-guest-os-discussion.61/>.

Voilà les étapes nécessaires :

1. On démarre la VM Linux avec le dernier kernel chargé. On est dans la
   situation où la réinstallation *classique* des Parallels Tools ne fonctionne
   pas avec le kernel chargé.
2. On insère le cdrom (menu *Action/Reinstall Parallels Tools*).
3. On monte le cdrom dans la VM.
4. On copie le contenu du cdrom dans un dossier temporaire.
5. On extrait l'archive du module.
6. On télécharge le patch pour la version du kernel depuis le forum Parallels,
   on le vérifie puis on l'applique.
7. On recompresse le module.
8. On lance l'installation.
9. On reboote la VM.

Voilà la liste des commandes (**commandes à taper en root**) :
```
mount -o exec /dev/sr0 /media/cdrom0
cp -r /media/cdrom0 /tmp/
cd /tmp/cdrom0/kmods
tar zxvf prl_mod.tar.gz && rm prl_mod.tar.gz
wget -O /path/to/patch/file <patch_url>
less /path/to/patch/file
patch -p1 < /path/to/patch/file
tar zcvf prl_mod.tar.gz .
cd ..
./install -i --verbose
reboot
```

[Un petit script qui fait ça](./install_patched_module.sh). Il faut fournir le
chemin du fichier de patch en argument.
