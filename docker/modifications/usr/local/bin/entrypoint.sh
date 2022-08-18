#!/bin/bash

#This script extract variables and put them into the config.php
#!/bin/bash

# Generate a new self signed SSL certificate when none is provided in the volume

CONFIG_FILE="/var/www/app/config.php"
PROJECT_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
TOKEN=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" -H "Metadata-Flavor: Google" | jq -r .access_token)

#Secret ID is from environment variable
echo $SECRET_ID
PAYLOAD=$(curl -s "https://secretmanager.googleapis.com/v1/projects/${PROJECT_ID}/secrets/${SECRET_ID}/versions/latest:access" \
--request "GET" \
--header "authorization: Bearer ${TOKEN}" \
--header "content-type: application/json"|jq -r ".payload.data")|base64 -d > ${CONFIG_FILE}

if [ ! -f /etc/nginx/ssl/kanboard.key  ] || [ ! -f /etc/nginx/ssl/kanboard.crt ]
then
    openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/nginx/ssl/kanboard.key -out /etc/nginx/ssl/kanboard.crt -subj "/C=GB/ST=London/L=London/O=Self Signed/OU=IT Department/CN=kanboard.org"
fi

chown -R nginx:nginx /var/www/app/data
chown -R nginx:nginx /var/www/app/plugins

exec /bin/s6-svscan /etc/services.d