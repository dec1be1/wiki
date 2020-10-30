tcpdump
=======

Pour lire dans le fichier /var/log/pflog :
```
# tcpdump -n -e -ttt -r /var/log/pflog
```

Pour lire sur l'interface eth0 en temps réel en filtrant le trafic TCP sur le port 22 :
```
# tcpdump -n -e -ttt -i eth0 -p tcp port 22
```

