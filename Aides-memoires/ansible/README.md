# Ansible

## Commandes ad hoc

Lorsqu'on ne veut exécuter que quelques tâches ponctuelles sur son inventory,
on n'a pas besoin de faire un playbook complet. On peut lancer des
commandes rapidement (*commandes ad hoc*).

```
ansible [pattern] -m [module] -a "[module options]"
```

### Installer un paquet

Sur toutes les machines du groupe webservers, sauf www1 et en faisant un
*update* du cache avant :

```
ansible -K -b webservers\:\!www1 -m ansible.builtin.apt -a "name=<package_name> state=present update_cache=yes"
```

### Supprimer un fichier

```
ansible debian -m file -a "path=/path/to/file state=absent"
```

### Exécuter une commande shell

```
ansible debian -m shell -a "whoami"
```

### Rebooter

```
ansible debian -a "/sbin/reboot"
```

### Sources

- <https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html>
