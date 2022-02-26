# OpenSSL

Quelques commandes utiles pour *openssl*.

## Création de certificats

### Clé privée

Pour générer une clé privée (pour création d'un certificat CA par exemple) :
```
openssl genrsa -des3 -out private/CA_flathouse.key 4096
```

### Certificat CA

Pour générer un certificat CA (autorité de certification) auto-signé :
```
openssl req -x509 -new -nodes -key private/CA_flathouse.key -days 3650 -out certs/CA_flathouse.pem
```

### Demande de certificat

Pour générer une demande de certificat (CSR). Avec cette commande, la clé
privée est générée en même temps :
```
openssl req -new -nodes -out certs/flathouse.org.pem -newkey rsa:4096 -keyout private/flathouse.org.key -sha256
```

### Signer la CSR

Pour signer la demande de certificat (CSR) avec le certificat CA :
```
openssl x509 -req  -sha256 -days 365 -in certs/flathouse.org.pem -out certs/flathouse.org.crt -CA certs/CA_flathouse.pem -CAkey private/CA_flathouse.key -CAcreateserial -CAserial ca.srl
```

Remarques :

* L'option `-CAcreateserial` n'est nécessaire que la première fois.
* Il faudra peut-être créer les fichiers suivants :
```
echo 1000 | sudo tee /etc/ssl/serial
sudo touch /etc/ssl/index.txt
```

### Conversion

Pour convertir le certificat au format `DER` (pour Android par exemple) :
```
openssl x509 -in certs/CA_flathouse.pem -outform der -out certs/CA_flathouse.der.crt
```

Pour convertir un certificat et sa clé privée dans le format PKCS#12
(pour import dans Firefox par exemple) :
```
openssl pkcs12 -export -out certificate.p12 -inkey privateKey.key -in certificate.crt -certfile CACert.crt
```

## Chiffrement de fichiers

Pour chiffrer un fichier avec par exemple *aes-256-cbc* :
```
openssl enc -aes-256-cbc -salt -in file -out file.enc
```

Pour déchiffrer :
```
openssl enc -d -aes-256-cbc -in file.enc -out file
```

## Génération de hash

On peut générer tout type de hash avec *openssl*. Par exemple, pour générer
le hash md5 du mot `p4ssw0rd` avec le salt `S4L7` :
```
openssl passwd -1 -salt S4L7 "p4ssw0rd"
```

## Génération d'aléa

On peut générer tout type d'aléa. Quelques exemples :
```
openssl rand -base64 256
openssl rand -hex 16
openssl rand -out random.bin 512
```

## RSA

Pour créer une clé privée :
```
openssl genrsa -out rsa_privkey.pem 4096
```

Pour créer la clé publique correspondante :
```
openssl rsa -in rsa_privkey.pem -pubout -out rsa_pubkey.pem
```

Pour chiffrer un fichier (avec la clé publique) :
```
openssl rsautl -encrypt -pubin -inkey rsa_pubkey.pem -in plain.txt -out cipher.txt
```

Pour déchiffrer (avec la clé privée) :
```
openssl rsautl -decrypt -inkey rsa_privkey.pem -in cipher.txt
```

Pour connaître le modulo n et l'exposant de chiffrage d'une clé publique :
```
openssl rsa -in rsa_pubkey.pem -pubin -text -modulus
```

Pour créer une clé privée à partir d'un fichier `asn1.conf`
(contenant `p`, `q` et `e`) :
```
openssl asn1parse -genconf asn1.conf -out private.der
```

Pour afficher les informations sur la clé privée créée :
```
openssl rsa -in private.der -inform der -text -check
```

Pour convertir la clé privée au format `pem` :
```
openssl rsa -in private.der -inform der -out private.pem -outform pem
```

## Informations

Pour afficher une CSR :
```
openssl req -text -noout -in CSR.csr
```

Pour afficher un certificat :
```
openssl x509 -in certificate.crt -text -noout
```

Pour un fichier PKCS#12 (fichier pfx ou p12) :
```
openssl pkcs12 -info -in keyStore.p12
```
