curl
====

Pour poster des données dans un formulaire :
```
$ curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "param1=value1&param2=value2" <url>
```

Pour poster des données au format *json* :
```
$ curl -X POST -H "Content-Type: application/json" -d '{"key1":"value1", "key2":"value2"}' <url>
```

On peut aussi mettre les données dans un fichier `data.txt` pour les formulaires ou `data.json` pour le json. Dans ce cas, les commandes deviennent :
```
$ curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d @data.txt <url>
$ curl -X POST -H "Content-Type: application/json" -d @data.json <url>
```


# Sources
* https://gist.github.com/subfuzion/08c5d85437d5d4f00e58