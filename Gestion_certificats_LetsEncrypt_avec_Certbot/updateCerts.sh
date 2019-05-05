#!/bin/bash
# Version du 04/06/2018

### VARIABLES ###

SSL_CERT_CHECK="/CHEMIN/ssl-cert-check -x 1"
IPTABLES="/sbin/iptables"
NGINX_PROD_PORT="8080"
NGINX_UPDATE_PORT="443"
NGINX_VHOSTS_DIR="/etc/nginx/sites-available"  # Sans slash a la fin
CERT_FILE="/etc/letsencrypt/live/DOMAIN_NAME.TLD/fullchain.pem"

### VERIFICATION DU CERTIFICAT ###

if [ ! -e $CERT_FILE ] ; then
   echo "$CERT_FILE file does not exist."
   exit 1;
fi

$SSL_CERT_CHECK -c $CERT_FILE | grep Valid
TO_UPDATE=$?

### MISE A JOUR SI NECESSAIRE ###

if [[ "$TO_UPDATE" -eq 1 ]]; then
   $IPTABLES -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
   for FILE in "$NGINX_VHOSTS_DIR"/*
   do
      /bin/sed -i -e "s/$NGINX_PROD_PORT/$NGINX_UPDATE_PORT/g" "$FILE"
   done
   /bin/ln -s $NGINX_VHOSTS_DIR/acme /etc/nginx/sites-enabled/acme
   /bin/systemctl restart nginx
   /usr/bin/certbot renew
   /bin/rm /etc/nginx/sites-enabled/acme
   for FILE in "$NGINX_VHOSTS_DIR"/*
   do
      /bin/sed -i -e "s/$NGINX_UPDATE_PORT/$NGINX_PROD_PORT/g" "$FILE"
   done
   /bin/systemctl restart nginx
   $IPTABLES -D INPUT -p tcp -m tcp --dport 443 -j ACCEPT
fi

exit 0
