# macos

## Fichiers

Changer les attributs d'un fichier (par exemple pour rendre un fichier caché) :

```sh
chflags hidden /path/to/file
```

Voir les attributs étendus d'un fichier :

```sh
xattr /path/to/file
```

## Périphériques bloc

Lister les périphériques :

```sh
diskutil list
```

## Réseau

Informations sur l'interface WiFi interne :

```sh
ifconfig en0
```

Obtenir la route par défaut :

```sh
route get default
```

Pour changer la route par défaut :

```sh
sudo route change default 192.168.0.254
```

Pour ajouter une route statique, par exemple vers le sous-réseau 
192.168.100.0/24 via la gateway 192.168.0.99 :

```sh
sudo route -n add -net 192.168.100.0/24 192.168.0.99
```

Pour supprimer la route :

```sh
sudo route -n delete 192.168.100.0/24
```

Pour afficher la table de routage :

```sh
netstat -nr
```

## UART

Pour repérer le bon périphérique :

```sh
ls -l /dev/cu.*
```

> Note : Attention aux droits de lecture/écriture sur le périphérique.

Connxion au port UART d'un périphérique à l'aide d'un FTDI (avec minicom) :

```sh
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

## Performances

Pour afficher les performances du GPU :

```sh
sudo powermetrics --samplers gpu_power -i 1000
```

## Tips pour gagner de l'espace de stockage

### Paramètres macos

Aller dans **Réglages Système → Général → Stockage** pour voir la répartition. 
Si _Données système_ dépasse 50 Go, il y a probablement de quoi récupérer.

### Snapshots Timemachine

Pour lister et supprimer un snapshot : 

```sh
tmutil listlocalsnapshots /
sudo tmutil deletelocalsnapshots AAAA-MM-JJ-HHMMSS
```

### Homebrew

```sh
brew cleanup -s
brew autoremove
```

Il peut aussi y avoir des anciennes versions de composants à vérifier ici (notamment Docker Desktop) : 

```sh
du -hd 1 /opt/homebrew/var/homebrew/tmp/.caskroom 2>/dev/null | sort -h | tail -10
```

Après vérification, pour faire le ménage pour Docker par exemple : 

```sh
sudo rm -rf /opt/homebrew/var/homebrew/tmp/.caskroom/docker-desktop/*
```

### IK Multimedia

#### Supprimer les installeurs

Les installeurs (fichiers `dmg`) de plugins sont stockés dans le dossier des sons (`~/Documents/IK Mumtimedia`par exemple).
On peut donc supprimer tous les fichiers `dmg`. Au pire, on peut toujours les réinstaller via _IK Product Manager_.

#### Supprimer un plugin

L'application _IK Product Manager_ ne permet pas de désinstaller des plugins. On ne peut que dé-autoriser et ré-installer.
Si on veut en supprimer un, on commence par le dé-autoriser puis on ferme toutes les applications (_IK Product Manager_, DAW).
On supprime les fichiers du plugin aux endroits suivants : 

- `/Applications/IK Multimedia/<plugin name>/` (the standalone app)
- `/Library/Audio/Plug-Ins/Components/` (Audio Unit)
- `/Library/Audio/Plug-Ins/VST/` (VST2)
- `/Library/Audio/Plug-Ins/VST3/` (VST3)
- `/Library/Application Support/Avid/Audio/Plug-Ins/` (AAX, Pro Tools)
- `~/Library/Application Support/IK Multimedia/<plugin name>/`
- `~/Library/Preferences/` (fichiers `com.ikmultimedia.<plugin name>*`)
- `~/Documents/IK Multimedia/<plugin name>/` (presets personnelles)

On peut chercher les éventuels fichiers restants : 

```sh
sudo find /Applications /Library ~/Library /Users/Shared -iname "*plugin_name*" 2>/dev/null
```

### Steinberg

Le mieux est de gérer les plugins depuis le _Steinberg Download Assistant_.

#### Supprimer les installeurs

Des installeurs (fichiers `dmg`) peuvent être stockés dans `~/Documents/Steinberg`.
On peut supprimer tous les fichiers `dmg`. 

### Caches divers

#### Hugging Face

```sh
du -sh ~/.cache/huggingface
rm -rf ~/.cache/huggingface
```

#### uv (python packages manager)

```sh
uv cache clean
```

#### pip

```sh
pip cache purge
```

### Recherche

Pour chercher les dossiers les plus volumineux : 

```sh
sudo du -xhd 1 /System/Volumes/Data 2>/dev/null | sort -h | tail -15
du -hd 1 ~ 2>/dev/null | sort -h | tail -15
```
