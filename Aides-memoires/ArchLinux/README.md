# Arch Linux

## pacman

### Commandes de base

Mettre à jour le système :
```
sudo pacman -Syu
```

Installer un paquet :
```
sudo pacman -S <package_name>
```

Désinstaller un paquet et toutes ses dépendances non utilisées par ailleurs :
```
sudo pacman -Rsu <package_name>
```

### Nettoyage du cache

Pour voir la taille occupée par les paquets en cache :
```
du -sh /var/cache/pacman/pkg/
```

Pour nettoyer le cache (par défaut, on garde les 3 dernières versions de
chaque paquets) :
```
sudo paccache -r
```

Pour ne garder qu'une seule version des paquets en cache :
```
sudo paccache -rk 1
```

Pour supprimer toutes les versions des paquets désinstallés :
```
sudo paccache -ruk0
```

Pour enlever tous les paquets (installés ou pas) du cache :
```
sudo pacman -Scc
```

Pour automatiser le nettoyage du cache, on peut créer un *hook* en créant le
fichier suivant :
```
sudo cat /etc/pacman.d/hooks/clean_package_cache.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *
[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -r
```

### Sources

- <https://wiki.archlinux.org/index.php/pacman>
- <https://ostechnix.com/recommended-way-clean-package-cache-arch-linux/>
