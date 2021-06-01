Splunk
======

On parle ici de la version gratuite : *Splunk Free*. Elle permet d'indexer
au maximum 500Mo/jour.


## Installation

On installe tout sur des machines de type GNU/Linux Debian.

Il faut d'abord créer un compte sur le site de Splunk pour pouvoir télécharger
le logiciel.

### Installation et configuration du serveur

#### Installation

Sur la machine qui servira de serveur *Splunk*, on télécharge le ficher *deb*
depuis le lien fourni puis on l'installe :
```
# wget -O splunk-8.1.3-63079c59e632-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.3&product=splunk&filename=splunk-8.1.3-63079c59e632-linux-2.6-amd64.deb&wget=true'
# dpkg -i dpkg -i splunk-8.1.3-63079c59e632-linux-2.6-amd64.deb
```

> Note : On peut vérifier la somme de contrôle md5. C'est vivement conseillé
  même si Splunk pourrait faire mieux pour garantir l'intégrité et
  l'authenticité de son logiciel !

On active Splunk au démarrage du serveur (il faudra accepter la license et
créer un compte administrateur à ce moment-là) puis on le lance :
```
# /opt/splunk/bin/splunk enable boot-start
# /opt/splunk/bin/splunk start
```

L'installation se fait par défaut dans `/opt/splunk`.

L'instance est alors accessible à l'adresse indiquée.

#### Configuration

Pour ajouter des ports d'écoute (pour recevoir les données depuis les
forwarders) :
*Settings/Forwarding and receiving/Receive data/New receiving port*.

On ajoute le port qu'on veut puis on relance l'instance :
*Settings/System/Server controls*.

> On crée un port de réception par forwarder.

### Installation et configuration du *Universal Forwarder*

#### Installation

Maintenant que le serveur est opérationnel, il faut lui envoyer des données.
Pour cela, on va installer le *Universal Forwarder* sur toutes les machines
dont on veut centraliser les logs.

Sur la machine qu'on veut monitorer, on télécharge le ficher *deb* depuis le
lien fourni puis on l'installe :
```
# wget -O splunkforwarder-8.1.3-63079c59e632-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.3&product=universalforwarder&filename=splunkforwarder-8.1.3-63079c59e632-linux-2.6-amd64.deb&wget=true'
# dpkg -i splunkforwarder-8.1.3-63079c59e632-linux-2.6-amd64.deb
```

L'installation se fait par défaut dans `/opt/splunkforwarder`.

On peut ensuite lancer le forwarder (il faut accepter la license et créer un
utilisateur administrateur à ce moment-là) :
```
# cd /opt/splunkforwarder/bin
# ./splunk start
```

> Note : Pour redémarrer le forwarder : `# ./splunk restart`.

On active le forwarder au démarrage du serveur :
```
# cd /opt/splunkforwarder/bin
# ./splunk enable boot-start
```

#### Configuration

Les fichiers de configuration du forwarder sont dans
`/opt/splunkforwarder/etc/system/local`.

Depuis le forwarder, on ajoute le serveur de réception :
```
# cd /opt/splunkforwarder/bin
# ./splunk add forward-server <IP_serveur_splunk>:<port_ecoute>
```

Cela crée un fichier `/opt/splunkforwarder/etc/system/local/outputs.conf`.

On ajoute ensuite un *monitor*, par exemple ici pour surveiller *nginx* :
```
# ./splunk add monitor /var/log/nginx/access.log -index access_rproxy
```

> L'index doit d'abord avoir été créé dans l'interface de *Splunk* :
  *Settings/Indexes*.

Pour lister les *monitor* :
```
# ./splunk list monitor
```

Pour supprimer un *monitor* :
```
# ./splunk remove monitor /var/log/nginx/access.log
```

## Sources

- <https://docs.splunk.com/Documentation>
- <https://geekeries.org/2018/03/installer-splunk-free-sur-debian-9/?cn-reloaded=1>
- <https://docs.splunk.com/Documentation/Forwarder/7.2.4/Forwarder/Installanixuniversalforwarder>
