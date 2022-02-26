# Procédure personnelle de mise à jour de mon serveur OpenBSD

Cette page décrit **ma** procédure de mise à jour d'un serveur sous OpenBSD.

Elle suppose de disposer de deux disques durs système strictement identiques :

* le disque dur *source*. C'est celui qui est actuellement dans le serveur en
  production. Il sera sauvegardé (bit à bit) vers le disque dur *cible*.
  Après la mise à jour, ce disque dur sera rangé dans un tiroir et pourra être
  réinstallé en cas de pépin sur le serveur.
* le disque dur *cible*. C'est celui qui est actuellement rangé dans un
  tiroir... il est en attente de remplacer le disque système en production en
  cas de soucis ou en attente de mise à jour. Dans le cas d'une mise à jour,
  il recevra la copie bit à bit du disque dur *source* puis le remplacera
  physiquement dans le serveur après cette copie réalisée. La mise à jour
  d'OpenBSD sera faite sur ce disque.

## Préparation logicielle

* Lancer une sauvegarde des machines virtuelles si nécessaire.
* Préparer une clé USB bootable avec par exemple
  [GParted Live](https://gparted.org/livecd.php).

## Préparation matérielle

* Arrêter le serveur (proprement... couper les machines virtuelles avant si
  nécessaire).
* Déconnecter les disques durs de données (les 3,5 pouces).
* Déconnecter le disque dur servant de sauvegarde des machines virtuelles et
  connecter à la place le disque dur cible (qui hébergera le système à
  mettre à jour).
* Redémarrer le système à l'aide de *GParted Live*.

## Copie bit à bit du disque dur système actuel

* Sous GParted Live, identifier correctement les disques durs pour éviter la
  cata... ! les disques SATA peuvent être branchés à chaud ;)
* Pour mettre le clavier en français : `# setxkbmap fr`
* Lancer la copie bit à bit du disque système actuel (qui sera ensuite
  démonté et conservé en cas de problème) vers le disque cible (dont le
  système sera mis à jour puis utilisé en production) :
```
sudo dd if=/dev/sda of=/dev/sdb conv=notrunc status=progress
```
* Attendre environ une heure pour un disque de 250 Go.
* Eteindre le serveur.

## Modification matérielle

* Installer le disque *cible* à la place du disque *source*.
* Remiser le disque *source* par devers moi ;D
* Remettre en place les disques durs de données (les 3,5 pouces).
* Démarrer le serveur.
* Vérifier les systèmes de fichiers, **en root** :
```
fsck
```

## Mise à jour d'OpenBSD

* Pour le système hôte (dom0), suivre la procédure disponible sur la FAQ
  officielle : <https://www.openbsd.org/faq/>
* Pour les machines virtuelles vmm/vmd : Cf. Aide-mémoire vmm/vmd
  (virtualisation OpenBSD)
