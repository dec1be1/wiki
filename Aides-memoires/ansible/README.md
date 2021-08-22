# Ansible

## Commandes ad hoc

Lorsqu'on ne veut exécuter que quelques tâches ponctuelles sur son inventory,
on n'a pas besoin de faire un playbook complet. On peut lancer des
commandes rapidement (*commandes ad hoc*).

```
$ ansible [pattern] -m [module] -a "[module options]"
```

### Supprimer un fichier

```
$ ansible debian -m file -a "path=/path/to/file state=absent"
```

### Exécuter une commande shell

```
$ ansible debian -m shell -a "whoami"
```

### Rebooter

```
$ ansible debian -a "/sbin/reboot"
```

### Sources

- <https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html>
