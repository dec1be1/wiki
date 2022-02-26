# Shell upgrade

Avec python :
```
python3 -c 'import pty; pty.spawn("/bin/bash")'
[CTRL]+z
stty raw -echo
fg
```
