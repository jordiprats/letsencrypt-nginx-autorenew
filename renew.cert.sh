#!/bin/bash

if [ -z "$1" ];
then
	echo "usage:"
	echo "$0 [config file]"
	echo
	exit 1
fi
DATEEXP=$(date -d '10000 years' +%s)

for i in $(find /etc/letsencrypt/live/ -iname $(grep domains $1  | cut -f2- -d=));
do
	EXPIRE=$(date -d "$(openssl x509 -in $i/cert.pem -noout -dates | grep notAfter | cut -f2- -d=)" +%s)

	if [ "$EXPIRE" -lt "$DATEEXP" ];
	then
		DATEEXP=$EXPIRE
	fi
done

REMAINING_DAYS=$(($(($DATEEXP-$(date +%s)))/86400))

if [ "$REMAINING_DAYS" -lt 21 ];
then
	echo autorenew
	/opt/letsencrypt/letsencrypt-auto certonly -a webroot --agree-tos --renew-by-default --webroot-path=/usr/share/nginx/html -d gitnific.cm.atlasit.com && service nginx restart
else
	echo "certificate up to date, remainig days: $REMAINING_DAYS"
fi

exit 0
