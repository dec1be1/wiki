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
