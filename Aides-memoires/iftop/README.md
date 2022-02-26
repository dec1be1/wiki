# iftop

*iftop* permet de monitorer les interfaces réseaux.

Pour filter un port en particulier (`-B` pour affichage en octets plutôt
qu'en bits ; `-i interface` pour spécifier une interface) :
```
sudo iftop -B -f "port https"
```
