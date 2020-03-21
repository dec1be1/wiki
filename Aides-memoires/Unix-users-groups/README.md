Utilisateurs et groupes Unix
============================

## Ajout d'un utilisateur à un groupe
Sous GNU/Linux, pour ajouter l'utilisateur `jean-clode` au groupe `winner` :
```
# adduser jean-clode winner
```

Sous OpenBSD, pour ajouter l'utilisateur `jean-clode` au groupe `winner` :
```
# usermod -G winner jean-clode
```

## Ajout d'un groupe
Sous GNU/Linux ou OpenBSD, pour ajouter le groupe `loser` :
```
# groupadd loser
```

## Création d'un utilisateur
Sous OpenBSD :
```
# useradd -m -u <UID> -g=uid -c "Commentaires" -d <HOME_DIRECTORY> -s <SHELL_PATH> <USERNAME>
```

## Changement uid et gid d'un utilisateur
Commandes pour changer l'*uid* et le *gid* d'un utilisateur Unix :
```
# usermod -u <NEWUID> <LOGIN>    
# groupmod -g <NEWGID> <GROUP>
# find / -user <OLDUID> -exec chown -h <NEWUID> {} \;
# find / -group <OLDGID> -exec chgrp -h <NEWGID> {} \;
# usermod -g <NEWGID> <LOGIN>
```

## Sources
* https://muffinresearch.co.uk/linux-changing-uids-and-gids-for-user/
