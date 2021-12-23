Packet Filter (pf)
==================

*Packet Filter* est le firewall du sysème *OpenBSD*.

Pour redémarrer pf avec la configuration de /etc/pf.conf :
```
# pfctl -d && pfctl -ef /etc/pf.conf
```

Pour voir le contenu d'une table (<abuse> par exemple) :
```
# pfctl -t abuse -T show
```

Pour effacer une adresse ip d'une table (<abuse> ici) :
```
# pfctl -t abuse -T del <adresse_ip>
```

Pour ajouter un élément à une table, utiliser la même syntaxe en remplaçant
`del` par `add`.
