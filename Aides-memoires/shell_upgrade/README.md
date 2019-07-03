Shell upgrade
=============

Avec python :
```
$ python -c 'import pty; pty.spawn("/bin/bash")'
[CTRL]+z
$ stty raw -echo
$ fg
```
