# Proxmox

## Disques virtuels

On ne peut pas attacher directement un fichier existant  d'image de disque dur
à une VM. Il faut d'abord l'importer dans la VM :
```
sudo qm importdisk <vm_id> <image_file_path> <storage_name> --format <image_format>
```

Par exemple, pour importer `file.qcow2` du storage `local` dans la VM 114 :
```
sudo qm importdisk 114 file.qcow2 local --format qcow2
```

Proxmox va alors créer une nouvelle image dans le dossier correspondant de la
VM (avec un nom de fichier normalisé) puis il va copier les données du disque
existant vers ce nouveau disque. On peut supprimer l'image original si elle
n'est plus utile.
Il faut aller ensuite dans l'onglet *Hardware* de la VM depuis l'interface
Proxmox pour ajouter le nouveau disque dur (qui apparaît comme un disque non
utilisé).

## Nettoyage vieux noyaux

Par défaut, PVE laisse en place tous les noyaux. On peut faire un peu de ménage
de temps en temps.

Pour lister les noyaux installés :
```
dpkg --list |grep pve-kernel
```

On peut alors supprimer ce qu'on veut avec `apt purge` (on peut utiliser un
wildcard `*`). 

## Création certificat Let's Encrypt pour la GUI de PVE

Selon l'architecture réseau mise en place, il est assez ennuyeux d'utiliser
un challenge de type *http*. On va donc configurer le tout pour un challenge
de type *dns*.

Le principe est que Proxmox va utiliser l'API du fournisseur de domaine (OVH
chez moi) pour créer dynamiquement un enregistrement dans la zone qui
permettra de prouver que ce domaine est bien sous mon contrôle.

### Création token API OVH

On se rend ici : <https://eu.api.ovh.com/createToken/>

Les droits suivants donne un accès complet aux domaines gérés par le compte :
```
GET /domain/zone/*
PUT /domain/zone/*
POST /domain/zone/*
DELETE /domain/zone/*
```

Pas terrible pour la sécurité mais pratique pour tester.

Pour une gestion plus fine des droits :
```
GET /domain/zone/
GET /domain/zone/{zoneName}/
GET /domain/zone/{zoneName}/status
GET /domain/zone/{zoneName}/record
GET /domain/zone/{zoneName}/record/*
POST /domain/zone/{zoneName}/record
POST /domain/zone/{zoneName}/refresh
DELETE /domain/zone/{zoneName}/record/*
```

On récupère alors :

- Application Key (AK)
- Application Secret (AS)
- Consumer Key (CK)

### Création challenge plugin

Dans Proxmox, *Datacenter/ACME*, *Add* et on remplit les champs en mettant
le type d'API sur *OVH*.

### Ajout domaine ACME

Dans Proxmox, *Node/System/Certificates*, *Add* et on remplit les champs.

Le plugin est celui qu'on a créé à l'étape au dessus.

Le *Domain* est le nom de sous-domaine affecté à Proxmox (par exemple
`pve.domain.tld`).

On peut alors demander un certificat en cliquant sur *Order Certificates Now*.
