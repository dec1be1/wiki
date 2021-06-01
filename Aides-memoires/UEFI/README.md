UEFI
====

Pour créer une clé USB bootable en *UEFI* :

* Créer une table de partitions `gpt` sur la clé (avec `fdisk` par exemple).
* Créer une partition (toujours avec `fdisk`).
* Mettre les flags `boot` et `esp` à la partition (avec `parted` par exemple).
* Créer un système de fichier sur la nouvelle partition
  (en *fat32* avec `mkfs.vfat`).
* Monter l'image iso sur laquelle on veut booter.
* Copier tous les fichiers de l'iso vers la clé USB.
* Booter sur la clé USB.
