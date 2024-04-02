# Ansible

## Commandes ad hoc

Lorsqu'on ne veut exécuter que quelques tâches ponctuelles sur son inventory,
on n'a pas besoin de faire un playbook complet. On peut lancer des
commandes rapidement (*commandes ad hoc*).

```
ansible [pattern] -m [module] -a "[module options]"
```

Si jamais on a besoin d'inclure les variables contenues dans un fichier 
(par exemple si on référence des variables dans le fichier d'inventaire), on 
peut les inclure avec `--extra-vars "@/path/to/vars_file.yml"`. Et on ajoute 
le *vault-id* si nécessaire (ici *core*) :
```
ansible [pattern] -m [module] -a "[module options]" --extra-vars "@/path/to/vars_file.yml" --vault-id=core@prompt
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
