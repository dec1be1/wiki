#!/usr/local/bin/bash

### Script permettant d'ajouter un utilisateur au vpn
### Il cree le certificat, la cle et le fichier de configuration
### selon : http://openbsdsupport.org/openvpn-on-openbsd.html

pkiDir="/etc/openvpn/easy-rsa-pki"
easyrsaDir="/usr/local/share/easy-rsa"
vpnclientuser="$1"

# On se place dans le repertoire de easy-rsa
cd ${easyrsaDir}

# On genere la demande de certificat pour le client
./easyrsa --batch=1 --pki-dir=${pkiDir} --req-cn=${vpnclientuser} gen-req ${vpnclientuser} nopass
ls -alpd ${pkiDir}/reqs/${vpnclientuser}.req ${pkiDir}/private/${vpnclientuser}.key
openssl req -in ${pkiDir}/reqs/${vpnclientuser}.req -text -noout
openssl rsa -in ${pkiDir}/private/${vpnclientuser}.key -check -noout

# On signe le certificat
./easyrsa --batch=1 --pki-dir=${pkiDir} show-req ${vpnclientuser}
./easyrsa --batch=1 --pki-dir=${pkiDir} sign client ${vpnclientuser}
openssl x509 -in ${pkiDir}/issued/${vpnclientuser}.crt -text -noout
cp -p ${pkiDir}/issued/${vpnclientuser}.crt /etc/openvpn/certs/${vpnclientuser}.crt
cp -p ${pkiDir}/private/${vpnclientuser}.key /etc/openvpn/private/${vpnclientuser}.key

# On cree le fichier de conf du client a partir du template
cp -p /etc/openvpn/private/vpnclient.conf.template /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn

# On insere le ca, cert, key et tls-auth au fichier de conf
echo "<ca>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
cat /etc/openvpn/certs/vpn-ca.crt >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
echo "</ca>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
echo "<cert>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
cat /etc/openvpn/certs/${vpnclientuser}.crt >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
echo "</cert>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
echo "<key>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
cat /etc/openvpn/private/${vpnclientuser}.key >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
echo "</key>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
echo "<tls-auth>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
cat /etc/openvpn/private/vpn-ta.key >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn
echo "</tls-auth>" >> /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn

# Ajustement des droits
chmod 600 /etc/openvpn/private-client-conf/vpnclient-${vpnclientuser}.conf.ovpn

# Fin du script
echo ""
echo "Fichier de configuration de "${vpnclientuser}" cree avec succes."
echo ""
exit 0
