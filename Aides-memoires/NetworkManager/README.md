Network Manager
===============

## Connexions

Pour lister les connexions disponibles :
```
$ nmcli connection show
```

Pour se connecter :
```
$ nmcli connection up <connection_name_or_uuid>
```

Ajouter `--ask` si un mot de passe est requis.

## Wifi

Pour lister les réseaux wifi :
```
$ nmcli device wifi list
```

Pour se connecter à un réseau wifi :
```
$ nmcli device wifi connect <SSID> password <password>
```

Pour se connecter à un réseau caché :
```
$ nmcli device wifi connect <SSID> password <password> hidden yes
```

## VPN

Pour installer une configuration depuis un fichier *ovpn* :
```
$ nmcli connection import type openvpn file <file.ovpn>
```






## Sources

- <https://wiki.archlinux.org/index.php/NetworkManager>
