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
