# adb

Mettre avant tout le périphérique en mode *débogage USB* (pour Android, les
options développeurs doivent être activées).

Pour lister les périphériques connectés :
```
adb devices
```

Pour faire un backup complet :
```
adb backup -all -apk -shared -f ./backup.ab
```

Pour restaurer :
```
adb restore ./backup.ab
```

Pour copier un fichier du téléphone vers l'ordinateur :
```
adb pull /sdcard/file local_destination_folder/
```

Pour copier un dossier entier de manière récursive, il faut ajouter `/.` à la 
fin :
```
adb pull /sdcard/folder/. local_destination_folder/
```
