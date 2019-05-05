Configuration PHP et Python dans un chroot OpenBSD
==================================================

Ce wiki explique comment faire fonctionner php et python dans un environnement chrooté sous OpenBSD.
Le chroot concerne ici l'exécution du serveur web (nginx) et est fait dans `/var/www`.

Le shell par défaut de l'utilisateur *root* doit être `/bin/sh`. D'une manière générale, ça élimine pas mal de problèmes, notamment parce que *bash* est dans la partition `/usr/local` qui n'est pas montée en mode *single user* (avec `boot -s` au démarrage).

## Modification des propriétés de montage de la partition `/var`

* Dans `/etc/fstab` : enlever les propriétés *nodev* et *nosuid* à la partition `/var`.
* Dans `/etc/fstab` : ajouter la propriété *wxallowed* à la partition `/var`.
* rebooter

## Copie des fichiers nécessaires dans le chroot

Copier les fichiers suivants dans le chroot (en recréant la structure des dossiers).

Pour php :
* /etc/resolv.conf
* /etc/hosts
* /etc/localtime
* /etc/ssl/cert.pem
* /usr/local/share/icu
* /usr/sbin/sendmail
* /etc/ssl/openssl.cnf


Pour python :
* /sbin/ldconfig
* /usr/lib/libc.so.X.X
* /usr/lib/libcrypto.so.X.X
* /usr/lib/libm.so.X.X
* /usr/lib/libncurses.so.X.X
* /usr/lib/libpthread.so.X.X
* /usr/lib/libreadline.so.X.X
* /usr/lib/libssl.so.X.X
* /usr/lib/libstdc++.so.X.X
* /usr/lib/libtermcap.so.X.X
* /usr/lib/libutil.so.X.X
* /usr/lib/libz.so.X.X
* /usr/libexec/ld.so
* /usr/local/bin/pydocX.X
* /usr/local/bin/pythonX.X
* /usr/local/bin/pythonX.X-config
* /usr/local/bin/pythonX.Xm
* /usr/local/bin/pythonX.Xm-config
* /usr/local/bin/pyvenv-X.X
* /usr/local/lib/libfcgi++.so.X.X
* /usr/local/lib/libfcgi.so.X.X
* /usr/local/lib/libiconv.so.X.X
* /usr/local/lib/libintl.so.X.X
* /usr/local/lib/libmysqlclient.so.X.X
* /usr/local/lib/libmysqlclient_r.so.X.X
* /usr/local/lib/libpythonX.X.so.X.X
* /usr/local/lib/mysql/libmysqlclient.so.X.X
* /usr/local/lib/mysql/libmysqlclient_r.so.X.X


Copier aussi le dossier `/usr/local/lib/pythonX.X` dans le chroot (uniquement les modules nécessaires).

Créer les liens symboliques vers la version python utilisée pour `pydoc`, `python` et `python-config` (voir dans le dossier d'origine `/usr/local/bin`).


Pour les *locale* (permet d'envoyer les commandes exécutées par la fonction php `exec()` en UTF-8 ; sinon la commande échoue lorsqu'elle comporte des caractères UTF-8) :

Copier le dossier `/usr/local/share/locale` et le fichier `/usr/share/locale/UTF-8/LC_CTYPE` dans le chroot.

## Création des nodes nécessaires

Taper les commandes suivantes :
```
# mknod -m 666 /var/www/dev/tty c 5 0
# mknod -m 666 /var/www/dev/null c 2 2
# mknod -m 644 /var/www/dev/random c 45 0
# mknod -m 644 /var/www/dev/urandom c 45 2
```

ou, pour tout créer d'un coup, utiliser le script `MAKEDEV` d'OpenBSD :
```
# cp /dev/MAKEDEV /var/www/dev/MAKEDEV
# cd /var/www/dev/
# ./MAKEDEV all
```

## Finalisation

Créer le dossier `/var/run` dans le chroot puis générer un fichier chrooté `ld.hints.so` :
```
# mkdir /var/www/var/run
# chroot /var/www /sbin/ldconfig /usr/lib /usr/local/lib
```

Pour tester python :
```
# chroot -u www /var/www /usr/local/bin/python
```

## Sources
* https://synacks.blogspot.fr/2009/01/django-on-openbsd.html
* https://yeuxdelibad.net/ah/#toc37
