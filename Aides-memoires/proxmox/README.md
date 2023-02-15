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

## Passthrough iGPU Intel

Le but ici est de pouvoir utiliser le GPU intégré dans un CPU Intel Core directement dans une VM. Un exemple d'application 
est d'utiliser le GPU dans une VM *Jellyfin* pour faire du transcodage vidéo hardware à la volée. 

Le test a été fait pour un Intel Core i5-6400 (Skylake) qui intègre un GPU Intel HD Graphics 530.

On va faire du *Split Passthrough*, par opposition au *Full Passthrough*. En Split, on va pouvoir utiliser 
le GPU à la fois dans l'hôte et dans une VM (cf. sources pour les détails).

L'hôte est un Proxmox version 7.3-6. La VM est une Debian 11.

### Sur l'hôte

On modifie la ligne de commande du kernel dans Grub (fichier `/etc/default/grub`) :
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on i915.enable_gvt=1 iommu=pt pcie_acs_override=downstream,multifunction video=efifb:off video=vesa:off vfio_iommu_type1.allow_unsafe_interrupts=1 kvm.ignore_msrs=1 modprobe.blacklist=radeon,nouveau,nvidia,nvidiafb,nvidia-gpu"
```

On met à jour Grub :
```
sudo update-grub
```

On ajoute ces lignes au fichier `/etc/modules` :
```
# Modules required for PCI passthrough
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd

# Modules required for Intel GVT-g Split
kvmgt
```

On met à jour le initramfs et on reboote le serveur :
```
sudo update-initramfs -u -k all
sudo reboot
```

On peut vérifier que l'IOMMU est activée après le reboot :
```
sudo dmesg | grep -e DMAR -e IOMMU
```

On doit voir `DMAR: IOMMU enabled` quelquepart.

### Dans la VM

On identifie l'adresse du GPU **sur l'hôte Proxmox** (on vérifie au passage qu'il apparaît toujours car on fait du 
split passthrough) :
```
sudo lspci -nnv | grep VGA
```

Ca doit être quelquechose qui ressemble à `00:02.0`.

Dans la configuration de la VM sur le Proxmox, on ajoute un périphérique PCI. On identifie le bon grâce à 
cette adresse. On choisit le *MDev Type* le plus performant. On laisse le reste par défaut (*ROM-Bar* est coché).

> Note : le type de machine doit être *i440fx*.

On boote la VM. On vérifie que le GPU apparaît **dans la VM** :
```
sudo lspci -nnv | grep VGA
cd /dev/dri && ls -la
```

Si le driver est bien chargé, on a un périphérique qui ressemble à `/dev/dri/renderD128`.

### Sources

- Split passthrough : <https://3os.org/infrastructure/proxmox/gpu-passthrough/igpu-split-passthrough/>
- Full passthrough : <https://3os.org/infrastructure/proxmox/gpu-passthrough/igpu-passthrough-to-vm/>