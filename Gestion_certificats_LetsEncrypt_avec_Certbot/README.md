Gestion des certificats Let's Encrypt avec Certbot sous GNU/Linux
=================================================================

Cette page décrit la procédure de création et de mise à jour des certificats *Let's Encrypt* avec le client [Certbot](https://certbot.eff.org/) sous Debian 9 (Stretch).
Le serveur web utilisé est *nginx*.
On utilisera le plugin pour *nginx* de *Certbot* pour faciliter l'utilisation.
Le port d'écoute du serveur web est par exemple le 8080 (il est donc ouvert dans le firewall). La configuration est plus simple avec les ports par défaut.
Un seul certificat sera créé. Il sera valable pour tous les sous-domaines. Si le serveur web gère plusieurs domaines, il faudra un certificat par domaine.

## Installation des packages nécessaires
```
# apt-get install certbot python-certbot-nginx
```
## Création du certificat (la première fois uniquement)
### Préparation du serveur web
* Avant de lancer la création des certificats, il faut que le serveur web fonctionne et que tous les hôtes virtuels (situés dans le dossier `/etc/nginx/sites-available`) qui nécessitent un certificat soient opérationnels et tournent **SANS TLS** (normal, on n'a pas encore de certificat...). Aussi, s'il y a des directives relatives à *TLS* dans les fichiers de configuration des hôtes virtuels, **elles doivent être commentées pendant la procédure de création du certificat**. Les liens symboliques doivent également être présents dans `/etc/nginx/sites-enabled`.

* Relancer le serveur web :
```
# systemctl restart nginx
```
### Modification temporaire du firewall (iptables)
On ouvre temporairement le port 443 qui est nécessaire pour le challenge *Let's Encrypt* (vérification que le serveur web est sous le contrôle de la bonne personne) :
```
# iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```
### Création du certificats
Si le serveur web a bien redémarré, on peut passer à la création du certificat. On utilise l'argument *certonly* de manière à éviter que *Certbot* ne modifie les fichiers de configuration de *nginx* :
```
# certbot --nginx certonly
```
S'il n'y a pas d'erreur, le certificat est créé (valable pour tous les sous-domaines). Le chemin du certificat et de la clé sont donnés à la fin de l'output de la commande précédente.

### Ajustement de la configuration du serveur web
Il faut maintenant éditer les fichiers de configuration des hôtes virtuels (dans `/etc/nginx/sites-available`) de manière à remettre (ou mettre si c'est vraiment la première fois) les directives relatives à la gestion de *TLS*. Voir la [documentation de nginx](https://nginx.org/en/docs/http/configuring_https_servers.html) pour plus d'informations.
Le chemin du certificat et de la clé privée créés juste avant doit être renseigné (directives *ssl_certificate* et *ssl_certificate_key*).

On relance le serveur web :
```
# systemctl restart nginx
```

### Remise en place de la configuration du firewall
Le port 443 n'a plus besoin d'être ouvert :
```
# iptables -D INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

### Post installation
A ce stade, une nouvelle tâche *crontab* a été créée automatiquement par *Certbot* pour gérer la mise à jour du certificat tous les 3 mois. On peut remplacer cette tâche par l'appel de notre script personnalisé (cf. juste après).

## Mise à jour du certificat
Cette procédure est automatisée par un petit script *bash* fait maison. Une tâche *crontab* l'appelle quotidiennement.
Ce script est disponible ici : [`/root/bin/updateCerts.sh`](./updateCerts.sh)

Pour mieux comprendre, voici son principe de fonctionnement :
* Appel du script `/root/bin/ssl-cert-check` qui permet de vérifier la validité du certificat. Voir [ici](http://prefetch.net/articles/checkcertificate.html) pour plus de détails sur ce script bien pratique.
* Si le certificat est encore valide, on sort du script ; sinon on passe à la procédure de mise à jour du certificat (ce cas se produit donc tous les 3 mois) :
 * On ouvre le port 443 pour permettre le challenge (ce port est obligatoirement utilisé par *Certbot*).
 * Modification du port d'écoute dans chaque fichier de configuration des hôtes virtuels : on passe du 8080 au 443 (la commande *sed* est utilisée dans le script).
 * On relance le serveur web.
 * On lance la commande de renouvellement du certificat : `# certbot renew`
 * On remet les hôtes virtuels en écoute sur le port 8080.
 * On relance le serveur web.
 * On ferme le port 443.
