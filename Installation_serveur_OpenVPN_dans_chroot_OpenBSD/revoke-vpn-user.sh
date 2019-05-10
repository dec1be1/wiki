#!/usr/local/bin/bash

### Script permettant de supprimer un utilisateur au vpn
### Il revoque le certificat de l'utilisateur
### selon : http://openbsdsupport.org/openvpn-on-openbsd.html

pkiDir="/etc/openvpn/easy-rsa-pki"
easyrsaDir="/usr/local/share/easy-rsa"
vpnclientuser="$1"
chroot="/var/openvpn/chrootjail"

# On se place dans le repertoire de easy-rsa
cd ${easyrsaDir}

# On revoque le certificat
./easyrsa --pki-dir=${pkiDir} revoke ${vpnclientuser}
./easyrsa --pki-dir=${pkiDir} gen-crl

# On verifie
egrep "${vpnclientuser}" ${pkiDir}/index.txt

# Modification des droits de crl.pem
chown :_openvpn ${pkiDir}/crl.pem; chmod g+r ${pkiDir}/crl.pem

# Verification que crl.pem est utilise dans server.conf
egrep '^ *crl-verify.*crl.pem' /etc/openvpn/server_tun0.conf

# Copie du nouveau crl.pem dans le dossier openvpn
cp -p ${pkiDir}/crl.pem $chroot/etc/openvpn/crl.pem
ls -alF ${pkiDir}/crl.pem /etc/openvpn/crl.pem /var/openvpn/chrootjail/etc/openvpn/crl.pem
openssl crl -in /etc/openvpn/crl.pem -text

# Fin du script
echo ""
echo "Voir le retour des commandes pour verifier que tout s'est bien passe."
echo ""
exit 0
