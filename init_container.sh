#!/bin/bash

set -e

php -v

# setup nginx log dir
# http://nginx.org/en/docs/ngx_core_module.html#error_log
sed -i "s|error_log /var/log/nginx/error.log;|error_log stderr;|g" /etc/nginx/nginx.conf

# setup server root
mkdir -p "$HOME_SITE"
chown -R www-data:www-data "$HOME_SITE/"

echo "INFO: creating /run/php/php7.0-fpm.sock ..."
rm -f /run/php/php7.0-fpm.sock
mkdir -p /run/php
touch /run/php/php7.0-fpm.sock
chown www-data:www-data /run/php/php7.0-fpm.sock
chmod 777 /run/php/php7.0-fpm.sock

echo "Starting SSH ..."
service ssh start

echo "Starting php-fpm ..."
service php7.0-fpm start

chmod 777 /run/php/php7.0-fpm.sock

echo "Starting Nginx ..."
/usr/sbin/nginx


