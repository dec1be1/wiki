hydra
=====

Hydra est un logiciel permettant de tester l'authentification d'un service (bruteforce logins/mots de passe).

Exemple pour un service web avec authentification par une méthode POST. Les noms des paramètres POST à passer sont `login`, `password` et `Submit` (qui est ici constant). Le message d'erreur contient `bad password` :
```
$ hydra -v -V -L /root/wordlists/metasploit/mirai_user.txt -P /root/wordlists/metasploit/mirai_pass.txt -s 80 example.org http-post-form "/login.php:login=^USER^&password=^PASS^&Submit=Login:bad password"
```
