Installation d'un serveur mail sous OpenBSD
===========================================

# Préambule
L'installation est réalisée sous OpenBSD 6.5. On va installer et configurer les éléments suivants :
* OpenSMTPD : le serveur mail par défaut d'OpenBSD (déjà installé)
* Dovecot : le serveur IMAP
* ClamAV et Clamsmtp : l'antivirus
* Spamd, Spampd et Spamassassin : gestion des spams
* DKIM Proxy : signature des mails sortants pour authentification

On note que PacketFilter (le firewall d'OpenBSD) va également jouer un grand rôle (filtrage de paquets, redirection de ports et réception des mails entrants).

On utilisera aussi *fetchmail* qui permet de récupérer les messages venant d'autres comptes pour les centraliser dans une seule boîte de réception.

# Installation des paquets
On installe les paquets nécessaires :
```
# pkg_add opensmtpd-extras dovecot dovecot-pigeonhole curl dkimproxy p5-Mail-SpamAssassin spampd clamav clamsmtp fetchmail
```

# Configuration du firewall (pf)
On va éditer le fichier `/etc/pf.conf`. Vers le début du fichier, on ajoute les tables qui vont être utilisées ainsi que les ports :
```
# Mail tables
table <mail_bruteforce> persist
table <spamd-white> persist
table <spamd> persist # updated by spamd-setup
table <nospamd> persist file "/etc/mail/nospamd"
```
```
mail_ports = "{ 25 587 993 }"
```

Un peu plus bas, dans les règles par défaut, on bloque et on loggue les paquets venant des méchants :
```
# Rejecting abuse and mail_bruteforce tables (and logging it)
block log quick from <abuse>
block log quick from <mail_bruteforce>
```

Ensuite, encore un peu plus bas, on autorise le trafic entrant sur les ports qui vont bien :
```
# Pass traffic on mail ports from outside
pass in quick on $ext_if inet proto tcp from !<abuse> to (egress) port $mail_ports
```

Enfin, on gère les redirections :
```
# Mail - imaps
pass in quick on egress proto tcp from any \
    to (egress) port imaps \
    flags S/SA modulate state \
    (max-src-conn 100, max-src-conn-rate 50/5, overload <mail_bruteforce> flush global)

# Mail - smtp
pass in quick log (to pflog1) on egress proto tcp \
    from { <nospamd> <spamd-white> } \
    to (egress) port { smtp } \
    flags S/SA modulate state

pass in quick proto tcp from { <spamd> } \
    to (egress) port { smtp, submission } \
    rdr-to 127.0.0.1 port spamd

pass in quick proto tcp from any \
    to (egress) port { smtp } \
    rdr-to 127.0.0.1 port spamd

pass in quick proto tcp from any \
    to (egress) port { submission } \
    flags S/SA modulate state \
    (max-src-conn 100, max-src-conn-rate 50/5, overload <mail_bruteforce> flush global)

# the rule below is to exempt any MTA that we send email to from spamd
# to ensure replies to our local users are delivered immediately
pass out quick log (to pflog1) on egress proto tcp to any port smtp
```

On n'oublie pas de redémarrer le firewall :
```
# pfctl -d && pfctl -ef /etc/pf.conf
```

# Configuration des différentes briques
## OpenSMTPD
On commence par créer l'utilisateur *vmail* pour séparer les droits avec les autres applications :
```
# useradd -m -u 1002 -g =uid -c "Virtual Mail" -d /var/vmail -s /sbin/nologin vmail
```

Le fichier de configuration principal est `/etc/mail/smtpd.conf`. Il est responsable de la transmission des messages entrants et sortants. Voilà un exemple : [`smtpd.conf`](./smtpd.conf).

Ce fichier fait appel à d'autres fichiers qu'on crée :
* [`users`](./users) : liste des adresses à prendre en compte et vers quel utilisateur les renvoyer.
* [`passwd`](./passwd) : liste des comptes utilisateurs avec le hash du mot de passe. Pour générer un hash blowfish, on peut utiliser cette commande : `dovecot pw -s BLF-CRYPT`.
* [`domains`](./domains) : liste de domaine à prendre en charge. On peut en mettre plusieurs si nécessaire.

On ajoute les adresses mail du serveur dans le fichiers `aliases`. On note que l'utilisateur *vmail* renvoie les mails vers `/dev/null`. Exemples de lignes à ajouter :
```
vmail: /dev/null
jean-clode: jean-clode@domain.tld
mickey: mickey@domain.tld
```

On régénère la base de données en tapant la commande : `# newaliases`.

On relance le service : `# rcctl restart smtpd`

## Dovecot
Dovecot est le serveur IMAP. Les fichiers de configuration se trouvent dans `/etc/dovecot`. Les modifications à faire sont les suivantes :
### `/etc/dovecot.conf`
* `protocols = imap lmtp`
* `listen = *, ::`

### `/etc/dovecot/conf.d/10-auth.conf`
* `disable_plaintext_auth = yes`
* `auth_username_chars = abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890.-_@`
* `!include auth-passwdfile.conf.ext`

### `/etc/dovecot/conf.d/10-mail.conf`
* ```
mail_home = /var/vmail/%d/%n
mail_location = mbox:~/mail:LAYOUT=maildir++:INDEX=~/mail/index:CONTROL=~/mail/control
```
* ```
namespace inbox {
    type = private
    separator = .
    [...]
}
```
* ```
mail_uid = vmail
mail_gid = vmail
```

### `/etc/dovecot/conf.d/10-ssl.conf`
* `ssl = yes`
* ```
ssl_cert = </etc/ssl/domain.tld.fullchain.pem
ssl_key = </etc/ssl/private/domain.tld.key
```
* `ssl_prefer_server_ciphers = yes`

### `/etc/dovecot/conf.d/15-lda.conf`
* `postmaster_address = postmaster@domain.tld`
* `hostname = mail.domain.tld`

### `/etc/dovecot/conf.d/15-mailboxes.conf`
* Ajouter `auto = subscribe` à toutes les sections `mailbox`
* Commenter la mailbox `"Sent Messages"`

### `/etc/dovecot/conf.d/20-lmtp.conf`
* `mail_plugins = $mail_plugins sieve`

### `/etc/dovecot/conf.d/auth-passwdfile.conf.ext`
```
# Authentication for passwd-file users. Included from 10-auth.conf.
#
# passwd-like file with specified location.
# <doc/wiki/AuthDatabase.PasswdFile.txt>

passdb {
  driver = passwd-file
  args = scheme=BLF-CRYPT /etc/mail/passwd
}

userdb {
  driver = static
  args = uid=vmail gid=vmail home=/var/vmail/%d/%n

  # Default fields that can be overridden by passwd-file
  #default_fields = quota_rule=*:storage=1G

  # Override fields from passwd-file
  #override_fields = home=/home/virtual/%u
}
```

On finit en générant les paramètres DH (c'est un peu long) :
```
# openssl dhparam -out /etc/dovecot/dh.pem 4096
```

On active et on démarre le service :
```
# rcctl enable dovecot
# rcctl start dovecot
```

## ClamAV
Les fichiers de configuration sont [`/etc/freshclam.conf`](./freshclam.conf) et [`/etc/clamd.conf`](./clamd.conf).

On lance la mise à jour des signatures : `/usr/local/bin/freshclam`.

On ajoute un crontab pour le faire régulièrement :
```
20 * * * * /usr/local/bin/freshclam >/dev/null 2>&1
```

On crée les fichiers de logs et on ajuste les droits :
```
# touch /var/log/clamd.log /var/log/freshclam.log
# chown _clamav:_clamav /var/log/clamd.log /var/log/freshclam.log
# chmod 640 /var/log/clamd.log /var/log/freshclam.log
```

On active le service et on le lance :
```
# rcctl enable clamd
# rcctl set clamd flags "-c /etc/clamd.conf"
# rcctl start clamd
```

## clamsmtp
Les fichiers de configuration sont [`/etc/clamsmtpd-in.conf`](./clamsmtpd-in.conf) et [`/etc/clamsmtpd-out.conf`](./clamsmtpd-out.conf).

On lance les services :
```
# /usr/local/sbin/clamsmtpd -f /etc/clamsmtpd-in.conf
# /usr/local/sbin/clamsmtpd -f /etc/clamsmtpd-out.conf
```

On ajoute ces lignes à `/etc/rc.local` pour les démarrer automatiquement au boot.

## spamd
On ajoute le service et on configure :
```
# rcctl enable spamd
# rcctl set spamd flags -v -G 2:4:864 -y 127.0.0.1 -K /etc/ssl/private/domain.tld.key -C /etc/ssl/domain.tld.fullchain.pem
# rcctl start spamd
```

On télécharge le fichier `nospamd` :
```
# ftp -o /etc/mail/nospamd http://www.bsdly.net/~peter/nospamd
```

On ajoute le contenu suivant au fichier `/etc/mail/spamd.conf` :
```
# Whitelist /etc/mail/nospamd (updated by crontab)
nospamd:\
	:white:\
	:method=file:\
	:file=/etc/mail/nospamd:
```

On ajoute l'adresse piège à spamd : `spamdb -T -a 'blackhole@domain.tld'`

On ajoute ce crontab :
```
*/10 * * * * /usr/libexec/spamd-setup
```

## spamlogd
On ajoute l'interface `pflog1` en créant le fichier [`/etc/hostname.pflog1`](./hostname.pflog1).

On lance l'interface : `# ifconfig pflog1 up description "spamlogd logging interface"`

On lance le service :
```
# rcctl enable spamlogd
# rcctl set spamlogd flags "-l pflog1"
# rcctl start spamlogd
```

## SpamAssassin et spampd
On active et on lance les services :
```
# rcctl enable spamassassin
# rcctl start spamassassin
# rcctl enable spampd
# rcctl set spampd flags "--port=10035 --relayhost=127.0.0.1:10036 --tagall"
# rcctl start spampd
```

Si on souhaite *whitelister* des adresses particulières, on peut le faire via le fichier `/etc/mail/spamassassin/local.cf`. Voir https://cwiki.apache.org/confluence/display/SPAMASSASSIN/ManualWhitelist pour plus de détails. Relancer les services après édition de ce fichier.

## DKIM Proxy
Le fichier de configuration est : [`/etc/dkimproxy_out.conf`](./dkimproxy_out.conf).

On crée le dossier `/etc/dkimproxy/private` et y copier les clés publique et privée (`public.key` et `private.key` qu'on peut obtenir à partir de la commande `dkim-genkey`).

On ajuste les droits :
```
# chown -R _dkimproxy:_dkimproxy /etc/dkimproxy
# chmod 700 /etc/dkimproxy/private
# chmod 444 /etc/dkimproxy/private/public.key
# chmod 400 /etc/dkimproxy/private/private.key
```

On active et lance le service :
```
# rcctl enable dkimproxy_out
# rcctl start dkimproxy_out
```

## Fetchmail
On commence par créer un utilisateur :
```
# useradd -m -u 3001 -g=uid -c "Fetchmail Daemon User" -d /var/fetchmail -s /sbin/nologin _fetchmail
```

*Fetchmail* va fonctionner de manière autonome et aura donc besoin de droits particuliers. On gère ça avec *doas*. On édite le fichier `/etc/doas.conf` et on ajoute ce contenu :
```
permit nopass setenv { HOME=/var/fetchmail USER=_fetchmail LOGNAME=_fetchmail } root as _fetchmail cmd /usr/local/bin/fetchmail
```

On crée le fichier de configuration `/var/fetchmail/.fetchmailrc`. Voici un exemple de contenu (on peut mettre plusieurs sections `poll` pour plusieurs comptes) :
```
set daemon 60
set postmaster 'jc'
set syslog

poll <imap_server> port 993 proto imap:
    user '<login>'
    password '<password>'
    is 'jc@domain.tld'
    options
        ssl
        #keep
        smtphost /var/dovecot/lmtp
```

On ajuste les droits de ce fichier car il contient des credentials.
```
# chmod 600 /var/fetchmail/.fetchmailrc
```

Fetchmail est lancé depuis le fichier `/etc/rc.local` :
```
# echo "/usr/bin/doas -u _fetchmail /usr/local/bin/fetchmail" >> /etc/rc.local
```

## Divers
Ajouter le contenu suivant au fichier `/etc/login.conf` :
```
dovecot:\
        :openfiles-cur=512:\
        :openfiles-max=2048:\
        :tc=daemon:
```

Il faudra rebooter pour prise en compte.

# Configuration de la zone DNS
Ajouter les champs suivants à la zone DNS. Penser également à configurer correctement le reverse DNS.

## Champ MX
`IN MX 1 mail.domain.tld.`

## Champ CNAME
`mail IN CNAME domain.tld.`

## Champ DMARC (TXT)
`_dmarc IN TXT "v=DMARC1; p=none"`

## Champ SPF
`600 IN TXT "v=spf1 a mx -all"`

## Champ DKIM
`pubkey._domainkey IN TXT "v=DKIM1;h=sha256;k=rsa;s=email;t=s;p=<...PUBLIC_KEY...>"`

# Sources
* https://www.openbsd.org/opensmtpd/
* https://frozen-geek.net/openbsd-email-server-1/
* http://technoquarter.blogspot.fr/2015/02/openbsd-mail-server-part-3-clamav-and.html
