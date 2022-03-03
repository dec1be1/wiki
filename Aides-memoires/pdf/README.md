# pdf

## Extraction de pages d'un fichier pdf
```
pdftk source.pdf cat 1-4 output destination.pdf
```

## Joindre plusieurs fichiers pdf
```
pdftk source1.pdf source2.pdf source3.pdf cat output destination.pdf
```

## Enlever le mot de passe d'un pdf chiffré
```
qpdf --password=<password> --decrypt input.pdf output.pdf
```

## Fichier texte vers pdf

```
enscript --header='$n||Page $% of $=' -p file.ps file.txt
ps2pdf file.ps file.pdf
```

> On peut personnaliser l'entête du fichier avec `enscript`. Voir le man.
> 
