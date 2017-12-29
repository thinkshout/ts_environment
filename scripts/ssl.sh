#!/bin/bash

mkdir -pv $(brew --prefix)/etc/nginx/ssl

SSLCONF=$(mktemp)
DNSNUM=2

cat config/ts-ssl.conf > $SSLCONF

for SITEDIR in ~/Sites/*/
do
    SITEDIR=${SITEDIR%*/}
	DNSNUM=$((DNSNUM + 1))
    echo "DNS.$DNSNUM = ${SITEDIR##*/}.localhost" >> $SSLCONF
	DNSNUM=$((DNSNUM + 1))
    echo "DNS.$DNSNUM = *.${SITEDIR##*/}.localhost" >> $SSLCONF
done

openssl req -config $SSLCONF -new -x509 -sha256 -newkey rsa:2048 -nodes \
    -keyout $(brew --prefix)/etc/nginx/ssl/dev.key -days 365 \
    -out $(brew --prefix)/etc/nginx/ssl/dev.crt

brew services restart nginx
