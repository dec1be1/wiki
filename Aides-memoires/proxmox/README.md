Proxmox
=======

## Disques virtuels

On ne peut pas attacher directement un fichier existant  d'image de disque dur
à une VM. Il faut d'abord l'importer dans la VM :
```
# qm importdisk <vm_id> <image_file_path> <storage_name> --format <image_format>
```

Par exemple, pour importer `file.qcow2` du storage `local` dans la VM 114 :
```
# qm importdisk 114 file.qcow2 local --format qcow2
```

Proxmox va alors créer une nouvelle image dans le dossier correspondant de la
VM (avec un nom de fichier normalisé) puis il va copier les données du disque
existant vers ce nouveau disque. On peut supprimer l'image original si elle
n'est plus utile.
Il faut aller ensuite dans l'onglet *Hardware* de la VM depuis l'interface 
Proxmox pour ajouter le nouveau disque dur (qui apparaît comme un disque non
utilisé).
