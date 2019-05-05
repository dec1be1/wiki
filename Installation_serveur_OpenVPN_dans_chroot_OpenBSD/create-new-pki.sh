#!/usr/local/bin/bash

### Script permettant de creer un nouveau pki (ou remettre a zero un pki)
### Il cree les repertoires certificats CA, serveur et cles privees
### selon : http://openbsdsupport.org/openvpn-on-openbsd.html

pkiDir="/etc/openvpn/easy-rsa-pki"
easyrsaDir="/usr/local/share/easy-rsa"
chroot="/var/openvpn/chrootjail"

# Ajustement configuration easy-rsa
if [ -f ${easyrsaDir}/vars ]; then
   \rm -f "${easyrsaDir}/vars";
fi
printf "set_var EASYRSA_CA_EXPIRE   3650\nset_var EASYRSA_CERT_EXPIRE   3650\nset_var EASYRSA_CRL_DAYS  3650\nset_var EASYRSA_KEY_SIZE   4096" > ${easyrsaDir}/vars;
cat ${easyrsaDir}/vars;


cd ${easyrsaDir}

# Initialisation du pki
./easyrsa --pki-dir=${pkiDir} init-pki
ls -alpd ${pkiDir} ${pkiDir}/*

# On cree le dh parameters
./easyrsa --batch=1 --pki-dir=${pkiDir} gen-dh
ls -alpd ${pkiDir}/dh.pem

# On cree le CA et on le verifie
./easyrsa --batch=1 --pki-dir=${pkiDir} --req-cn=vpn-ca build-ca nopass
ls -alpd ${pkiDir}/ca.crt ${pkiDir}/private/ca.key ${pkiDir}/index.txt ${pkiDir}/serial
openssl x509 -in ${pkiDir}/ca.crt -text -noout
openssl rsa -in ${pkiDir}/private/ca.key -check -noout

# On genere une requete de certificat pour le serveur
./easyrsa --batch=1 --pki-dir=${pkiDir} --req-cn=vpnserver gen-req vpnserver nopass
ls -alpd ${pkiDir}/reqs/vpnserver.req ${pkiDir}/private/vpnserver.key
openssl req -in ${pkiDir}/reqs/vpnserver.req -text -noout
openssl rsa -in ${pkiDir}/private/vpnserver.key -check -noout

# On signe la requete de certificat du serveur
./easyrsa --batch=1 --pki-dir=${pkiDir} show-req vpnserver
./easyrsa --batch=1 --pki-dir=${pkiDir} sign server vpnserver
ls -alpd ${pkiDir}/issued/vpnserver.crt ${pkiDir}/certs_by_serial/01.pem
openssl x509 -in ${pkiDir}/issued/vpnserver.crt -text -noout
echo "Last added cert in db: `cat ${pkiDir}/index.txt|tail -1`"
echo "Next added cert will have number: `cat ${pkiDir}/serial`"

# On cree un crl vide (certificat revocation list)
./easyrsa --batch=1 --pki-dir=${pkiDir} gen-crl
chown :_openvpn ${pkiDir}/crl.pem; chmod g+r ${pkiDir}/crl.pem
ls -alF ${pkiDir}/crl.pem
openssl crl -in ${pkiDir}/crl.pem -text -noout

# On cree le fichier vpn-ta.key pour authentification
openvpn --genkey --secret ${pkiDir}/private/ta.key

# On copie les fichiers crees dans les bons repertoires
cp -p ${pkiDir}/ca.crt /etc/openvpn/certs/vpn-ca.crt
cp -p ${pkiDir}/private/ca.key /etc/openvpn/private/vpn-ca.key
cp -p ${pkiDir}/issued/vpnserver.crt /etc/openvpn/certs/vpnserver.crt
cp -p ${pkiDir}/private/vpnserver.key /etc/openvpn/private/vpnserver.key
cp -p ${pkiDir}/dh.pem /etc/openvpn/dh.pem
cp -p ${pkiDir}/crl.pem $chroot/etc/openvpn/crl.pem
ln -s $chroot/etc/openvpn/crl.pem /etc/openvpn/crl.pem
cp -p ${pkiDir}/private/ta.key /etc/openvpn/private/vpn-ta.key

# Verifications certificats et cles
openssl x509 -in /etc/openvpn/certs/vpn-ca.crt -text -noout
openssl x509 -in /etc/openvpn/certs/vpnserver.crt -text -noout
openssl crl -in /etc/openvpn/crl.pem -text -noout
openssl rsa -in /etc/openvpn/private/vpn-ca.key -check -noout
openssl rsa -in /etc/openvpn/private/vpnserver.key -check -noout

# Fin du script
echo ""
echo "Nouveau pki cree avec succes dans "${pkiDir}"."
echo ""
exit 0
