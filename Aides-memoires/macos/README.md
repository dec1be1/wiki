# macos

## Fichiers

Changer les attributs d'un fichier (par exemple pour rendre un fichier caché) :
```
chflags hidden /path/to/file
```

Voir les attributs étendus d'un fichier :
```
xattr /path/to/file
```

## Périphériques bloc

Lister les périphériques :
```
diskutil list
```

## Réseau

Informations sur l'interface WiFi interne :
```
ifconfig en0
```

Obtenir la route par défaut :
```
route get default
```

Pour ajouter une route statique, par exemple vers le sous-réseau 
192.168.100.0/24 via la gateway 192.168.0.99 :
```
sudo route -n add -net 192.168.100.0/24 192.168.0.99
```

Pour supprimer la route :
```
sudo route -n delete 192.168.100.0/24
```

Pour afficher la table de routage :
```
netstat -nr
```