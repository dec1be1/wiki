Mariadb : Gestion des binary logs
=================================

Le dossier `/var/mysql/mysql` contient les logs binaires (fichiers de la forme `mysql-bin.00000*`) qui peuvent prendre beaucoup de place au bout d'un moment. Ces logs sont utilisés par la fonctionnalité de *replication* qui permet notamment de créer des serveurs *mirror* (esclaves) d'un serveur maître (master). Cette fonctionnalité n'est pas utile pour un petit serveur comme le mien (sans esclaves). Je la laisse toutefois activée mais je paramètre l'effacement automatique des logs binaires après une durée relativement courte.

## Gestion des Binary Logs
### Dans la console
Les commandes suivantes sont à taper dans une console `mysql`.

Pour voir les logs binaires :
```
SHOW BINARY LOGS;
```

Pour effacer tous les logs binaires d'un coup :
```
RESET MASTER;
```

Pour effacer les logs antérieurs à une certaine date :
```
PURGE BINARY LOGS BEFORE '2013-04-22 09:55:22';
```
ou :
```
PURGE BINARY LOGS BEFORE '2013-04-22';
```

### Paramétrage du serveur
Pour effacer automatiquement les logs binaires après *X* jours, ajouter la ligne suivante dans le fichier de configuration (`/etc/my.cnf`) :
```
expire_logs_days = X
```

## Sources

* https://mariadb.com/kb/en/library/binary-log/
* https://mariadb.com/kb/en/library/replication-overview/
* https://mariadb.com/kb/en/library/using-and-maintaining-the-binary-log/
