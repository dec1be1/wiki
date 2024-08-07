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

Pour changer la route par défaut :
```
sudo route change default 192.168.0.254
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

## UART

Pour repérer le bon périphérique :
```
ls -l /dev/cu.*
```

> Note : Attention aux droits de lecture/écriture sur le périphérique.

Connxion au port UART d'un périphérique à l'aide d'un FTDI (avec minicom) :
```
minicom -s /dev/cu.usbserial-0001
```

Il faudra peut-être régler le périphérique à nouveau dans minicom. Régler les 
paramètres série également si nécessaire.

## Désinstallation programme

Mettre l'application dans la corbeille puis supprimer les fichiers relatifs à 
l'application dans les dossiers suivants :

- `~/Library/`
- `~/Library/Preferences/`
- `~/Library/Application Support/`
- `~/Library/Application Scripts/`
- `~/Library/Logs/`
- `~/Library/Caches/`
- `~/Library/Cookies/`
- `~/Library/Containers/`
- `~/Library/Group Containers/`
- `~/Library/Saved Application State/`
- `~/Library/WebKit/`
- `/Users/Shared/`
- `/Library/`
- `/Library/Application Support/`
- `/Library/Caches/`
- `/Library/Logs/`

## Configuration clavier dans VM Kali sur VMWare Fusion 13

### Configuration VM dans VMWare Fusion

Dans la section *Keyboard and mouse*, dans *Key Mappings* :

- choisir le profil *Mac Profile* (le créer s'il n'existe pas)
- cocher *Enable Key Mappings*
- décocher *Enable Language Specific Key Mappings*
- Créer 2 mappings :
  + `@` -> `<`
  + `<` -> `@`

### Dans la VM

Paramètres *Keyboard* dans Gnome :

- Keyboard Model : Generic 105-key PC
- Keyboard Layout : French
- Keyboard Variant : French (Macintosh)

Fichier `/etc/default/keyboard` :
```
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="fr"
XKBVARIANT="mac"
XKBOPTIONS="lv3:lalt_switch,compose:lwin"

BACKSPACE="guess"
```
