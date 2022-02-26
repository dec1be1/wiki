# Nextcloud

Pour ajuster les droits du répertoire `nextcloud` :
```
sudo chown -R www-data:www-data /var/www/nextcloud
sudo find /var/www/nextcloud/ -type d -exec chmod 750 {} \;
sudo find /var/www/nextcloud/ -type f -exec chmod 640 {} \;
```
