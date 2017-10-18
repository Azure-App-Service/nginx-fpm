#!/bin/bash
log(){
	while read line ; do
		echo "`date '+%D %T'` $line"
	done
}

set -e
logfile=/home/LogFiles/entrypoint.log
test ! -f $logfile && mkdir -p /home/LogFiles && touch $logfile
exec > >(log | tee -ai $logfile)
exec 2>&1

set -x
nginx_conf=/etc/nginx/sites-enabled/default.conf

# set nginx rewrite to resolve 404 error
sed -i '$d' $nginx_conf
sed -i 's|$uri/ =404|$uri/ @rewrite|g' $nginx_conf
echo $'location @rewrite {\n rewrite ^/(.*)$ /index.php?q=$1;\n }\n}' >> $nginx_conf

# set fastcgi_read_timeout to resolve 504 gateway time out
sed -i '/include fastcgi_params;/a\fastcgi_read_timeout 300;' $nginx_conf

if [ ! -d "/home/site/wwwroot/docroot" ]; then
  mkdir -p /home/site/wwwroot/docroot
fi
drush @none dl registry_rebuild-7.x

if [ ! -z "$PORT" ];then
	sed -i -e "s/listen   80/listen   ${PORT}/" $nginx_conf
fi

ssh-keygen -A
/usr/sbin/sshd

/start.sh
