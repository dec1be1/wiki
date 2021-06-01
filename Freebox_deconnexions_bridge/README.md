Freebox : Problème de déconnexions intempestives en mode bridge
===============================================================

## Préambule

Beaucoup d'abonnés *Free* utilisant leur Freebox en mode bridge constate un
problème de déconnexions intempestives du lien internet (la téléphonie et la
télévision continuent de fonctionner).
La seule solution trouvée à ce jour est le reboot de la Freebox. On peut bien
sûr débrancher/rebrancher la box brutalement. On peut aussi utiliser l'API de
*Free* pour initier ce reboot.

On va utiliser un **Raspberry Pi Zero connecté au réseau local** et ce dépôt :
<https://gitlab.com/benzoga33/reboot_freebox>.
On note qu'il faut que le Raspberry puisse envoyer des mails pour les
notifications en cas de reboot.

> Note : Si on veut juste un script plus simple pour faire un reboot manuel
  ponctuellement, on peut utiliser ce dépôt :
  <https://github.com/kmmndr/reboot-fbx>

## Accès de l'application de reboot à la box

On commence par autoriser notre application qui va gérer le reboot à accéder
à la Freebox. Pour ça, il faut obtenir un token de la Freebox.
On clone le dépôt suivant, on charge les fonctions de l'API dans le shell et
on demande le token :
```
$ git clone https://gitlab.com/benzoga33/reboot_freebox.git
$ cd reboot_freebox
$ source ./freeboxos_bash_api.sh
$ authorize_application 'rebootFbox.sh' 'script reboot freebox' '1.0.0' 'routeur'
```

A ce moment-là, il faut physiquement autoriser l'application sur l'écran LCD
de la Freebox. Lorsque c'est fait, on récupère le token et on note sa valeur
qu'on devra coller dans le script `rebootFbox.sh`.

Il faut ensuite rectifier les autorisations de l'application depuis
l'interface de gestion de la Freebox. On y accède à l'adresse
<http://212.27.38.253> (<http://mafreebox.freebox.fr>).
On se connecte en administrateur et on va dans le menu
"Paramètres de la Freebox/Gestion des accès/Applications". On peut conserver
uniquement l'accès *Modification des réglages de la Freebox*.

## Automatisation

Pour que la Freebox redémarre en cas de déconnexion, on va appeler le
script `rebootFbox.sh` toutes les 2 minutes pour vérifier la connectivité et
rebooter la Freebox si elle est perdue.

On ajuste les paramètres dans le script `rebootFbox.sh` :

- Adresse de la gateway Free à pinger
- Token d'authentification fourni par la Freebox juste avant
- Adresse mail

On ajoute une tâche dans le crontab :
```
pi@zero:~/bin/reboot_freebox $ crontab -l
*/2 * * * * /home/pi/bin/reboot_freebox/rebootFbox.sh
```

Et voilà !

## Sources

* <https://tutox.fr/2019/12/12/resoudre-le-bug-de-deconnexion-de-la-freebox-mode-bridge/>
* <https://dev.freebox.fr/sdk/os/system/>
* <https://dev.freebox.fr/bugs/task/22818>
