qemu
====

# Quelques combinaisons de touches
Pour accéder au *monitor* de qemu : `[CTRL]+a` puis `c`
Pour rebasculer dans la vm : `[CTRL]+a` puis `c` puis `[ENTER]`
Pour quitter qemu : `[CTRL]+a` puis `x` (ou `q` depuis le *monitor*)

# Image disque
Pour créer une image disque (taille maximale de 20 Go) :
```
$ qemu-img create -f qcow2 disk.qcow2 20G
```

# Démarrage d'une machine virtuelle
Le script [qemu-start.sh](./qemu-start.sh) permet de lancer une machine virtuelle avec qemu.
