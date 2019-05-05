OpenSSH
=======

Pour renouveler les clés d'un serveur ssh (utile lorsqu'on utilise des images pré-installées type ''kali'' par exemple) :
```
# rm /etc/ssh/ssh_host_*
# dpkg-reconfigure openssh-server
# service ssh restart
```

Pour voir les identités chargées dans l'agent ssh :
```
$ ssh-add -l
```

Pour télécharger un fichier depuis un serveur (lorsque **scp** n'est pas disponible) :
```
$ ssh login@server cat file > /tmp/file
```

Pour uploader un fichier sur un serveur  (lorsque **scp** n'est pas disponible) :
```
$ ssh login@server < file "cat > /tmp/file"
```
