# sed

Pour remplacer une chaîne de caractères par une autre dans un fichier
(pratique pour éditer un fichier depuis le noyau `bsd.rd` d'*OpenBSD* par
exemple) :
```
sed -i 's/ChaineARemplacer/NouvelleChaine/' fichier
```

Pour remplacer une chaîne de caractères récursivement dans plusieurs
fichiers :
```
egrep -lRZ 'foo' . |xargs -0 -l sed -i -e 's/foo/bar/g'
```
