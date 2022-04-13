# xrandr

## Ajout mode non reconnu

Pour ajouter un mode d'affichage non reconnu :

- On récupère le *Modeline* avec `cvt`.
- On crée le mode.
- On l'ajoute à l'écran (*DP-3* dans l'exemple en dessous).
- On l'active sur l'écran

Par exemple :
```
cvt 1920 1080
xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
xrandr --addmode DP-3 1920x1080_60.00
xrandr --output DP-3 --mode 1920x1080_60.00
```

Attention, les modifications ne sont pas permanentes. Pour conserver le
mode d'affichage créé, il faut créer le fichier
`/etc/X11/xorg.conf.d/10-monitor.conf` avec le contenu suivant :

```
Section "Monitor"
    Identifier "DP-3"
    Modeline "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
    Option "PreferredMode" "1920x1080_60.00"
EndSection
```

Et faire ensuite un script xrandr ou utiliser un outil pour appliquer la
configuration au démarrage.

## Divers

Pour voir les écrans connectés et actifs :
```
xrandr | grep " connected"
```

## Sources

- <https://wiki.archlinux.org/title/xrandr>
