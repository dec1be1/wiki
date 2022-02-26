# tcpdump

Pour lire dans le fichier /var/log/pflog :
```
sudo tcpdump -n -e -ttt -r /var/log/pflog
```

Pour lire dans un fichier en temps réel :
```
tail -f -c +1 <cap_file> | sudo tcpdump -l -r -
```

Pour lire sur l'interface eth0 en temps réel en filtrant le trafic TCP sur le
port 22 :
```
sudo tcpdump -n -e -ttt -i eth0 -p tcp port 22
```
