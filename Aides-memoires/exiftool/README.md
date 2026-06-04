# exiftool

## Données GPS

Pour supprimer toutes les données GPS d'une photo : 
```
exiftool -overwrite_original -gps\*= *.jpg
```

Pour vérifier : 

```
exiftool -gps\* *.jpg
```

> [!NOTE]
> Si on utilise *zsh*, il faut échapper le `*` dans le paramètre `-gps`.

