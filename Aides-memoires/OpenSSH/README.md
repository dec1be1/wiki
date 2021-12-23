OpenSSH
=======

## Renouvellement clés serveur

Pour renouveler les clés d'un serveur ssh (utile lorsqu'on utilise des images
pré-installées type ''kali'' par exemple) :
```
# rm /etc/ssh/ssh_host_*
# dpkg-reconfigure openssh-server
# service ssh restart
```

## Agent SSH

Pour voir les identités chargées dans l'agent ssh :
```
$ ssh-add -l
```

## Tricks transfert de fichier

Pour télécharger un fichier depuis un serveur (lorsque **scp** n'est pas
disponible) :
```
$ ssh login@server cat file > /tmp/file
```

Pour uploader un fichier sur un serveur  (lorsque **scp** n'est pas
disponible) :
```
$ ssh login@server < file "cat > /tmp/file"
```

## Format clés privées

Certains logiciels utilisent des clés privées au format *ppk*
(format de *PuTTY*). C'est le cas par exemple de *Filezilla*. Pour générer
une clé au format *ppk* à partir d'une clé au format *OpenSSH*, on peut
utiliser la version Linux de *PuTTY*.

Pour l'installer (sous Arch ou sous Debian) :
```
# pacman -S putty
# apt install putty-tools
```

On peut ensuite convertir la clé privée `privatekey` avec la commande :
```
$ puttygen private_key -o private_key.ppk
```
