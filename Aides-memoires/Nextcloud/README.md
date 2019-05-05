Nextcloud
=========

Pour ajuster les droits du répertoire `nextcloud` :
```
# chown -R www:www /var/www/nextcloud
# find /var/www/nextcloud/ -type d -exec chmod 750 {} \;
# find /var/www/nextcloud/ -type f -exec chmod 640 {} \;
    ```
