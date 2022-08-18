#!/bin/bash

#This script extract variables and put them into the config.php
#!/bin/bash

CONFIG_FILE="/var/www/app/config.php"
cp /secrets/config.php $CONFIG_FILE

if [ ! -f /etc/nginx/ssl/kanboard.key  ] || [ ! -f /etc/nginx/ssl/kanboard.crt ]
then
  openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/nginx/ssl/kanboard.key -out /etc/nginx/ssl/kanboard.crt -subj "/C=GB/ST=London/L=London/O=Self Signed/OU=IT Department/CN=kanboard.org"
fi

if [ -d /var/www/app/data ]; then
  chown -R nginx:nginx /var/www/app/data
fi
if [ -d /var/www/app/plugins ]; then
  chown -R nginx:nginx /var/www/app/plugins
fi

exec /bin/s6-svscan /etc/services.d