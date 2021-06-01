httrack
=======

Pour télécharger un site web en entier :
```
$ httrack --connection-per-second=50 --sockets=80 --keep-alive --display --verbose --advanced-progressinfo --disable-security-limits -n -i -s0 -m -A100000000 -#L500000000 'https://site.org'
```

## Sources

* <https://www.archiveteam.org/index.php/HTTrack_options>
