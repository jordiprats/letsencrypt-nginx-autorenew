#!/bin/bash

cd /opt/letsencrypt
git pull

if [ -z "$1" ];
then
	echo "usage:"
	echo "$0 [config file]"
	echo
	exit 1
fi

if [ ! -d "/etc/letsencrypt/live/" ];
then
	echo "requesting cert"
	for i in $(grep domains $1  | cut -f2- -d=);
	do
		/opt/letsencrypt/letsencrypt-auto certonly --standalone -d $i --register-unsafely-without-email
	done
	
	exit 0
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

if [ "$REMAINING_DAYS" -lt 15 ];
then
	echo autorenew
	for i in $(find /etc/letsencrypt/live/ -iname $(grep domains $1  | cut -f2- -d=));
	do
		/opt/letsencrypt/letsencrypt-auto certonly -a webroot --agree-tos --renew-by-default --webroot-path="$(grep webroot-path $1 | sed 's@[ ]*webroot-path[ ]*=[ ]*@@')" -d "$(basename $i)" && service nginx restart
	done
else
	echo "certificate up to date, remainig days: $REMAINING_DAYS"
fi

exit 0
