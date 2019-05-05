tcpdump
=======

Pour lire sur l'interface pflog0 en temps réel :
```
# tcpdump -n -e -ttt -i pflog0
```

Pour lire dans le fichier /var/log/pflog :
```
# tcpdump -n -e -ttt -r /var/log/pflog
```
