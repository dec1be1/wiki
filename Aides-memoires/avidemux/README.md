# avidemux

## Batch processing

Pour réaliser les mêmes actions sur plusieurs fichiers, réaliser les étapes
suivantes :

1. Ouvrir avidemux et faire les réglages sur le premier fichier.
2. Enregistrer le script python correspondant au traitement :
   *File/Project script/Save as project*
3. Editer le script en supprimant les variables relatives au fichier :
   - `adm.loadVideo`
   - `adm.clearSegments`
   - `adm.addSegment`
   - `adm.markerA`
   - `adm.markerB`
4. On peut alors utiliser `avidemux3_cli` dans une boucle bash. Voir
   [ce script](./process.sh) pour l'exemple.


## Sources

- <https://www.gaelanlloyd.com/blog/batch-processing-video-files-with-avidemux/>
