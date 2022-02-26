# Utilisateurs et groupes Unix

## Ajout d'un utilisateur à un groupe

Sous GNU/Linux ou OpenBSD, pour ajouter l'utilisateur `jean-clode` au
groupe `winner` :
```
sudo usermod -aG winner jean-clode
```

## Ajout d'un groupe

Sous GNU/Linux ou OpenBSD, pour ajouter le groupe `loser` :
```
sudo groupadd loser
```

## Création d'un utilisateur

Sous OpenBSD :
```
sudo useradd -m -u <UID> -g=uid -c "Commentaires" -d <HOME_DIRECTORY> -s <SHELL_PATH> <USERNAME>
```

## Changement uid et gid d'un utilisateur

Commandes pour changer l'*uid* et le *gid* d'un utilisateur Unix :
```
sudo usermod -u <NEWUID> <LOGIN>    
sudo groupmod -g <NEWGID> <GROUP>
sudo find / -user <OLDUID> -exec chown -h <NEWUID> {} \;
sudo find / -group <OLDGID> -exec chgrp -h <NEWGID> {} \;
sudo usermod -g <NEWGID> <LOGIN>
```

## Sources

* <https://muffinresearch.co.uk/linux-changing-uids-and-gids-for-user/>
