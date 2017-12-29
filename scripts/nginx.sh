#!/bin/bash

if brew list nginx; then
	echo ""
	echo "Configuring nginx"
	echo ""

	sudo launchctl unload /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null

	mkdir -pv ~/Sites
	echo '<?php phpinfo();' > ~/Sites/index.php

	export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}')

	cat config/nginx.conf > $(brew --prefix)/etc/nginx/nginx.conf
	sed -i -e "s#\${USERHOME}#$USERHOME#g" $(brew --prefix)/etc/nginx/nginx.conf

	cat config/ts-dev.conf > $(brew --prefix)/etc/nginx/ts-dev.conf
	sed -i -e "s#\${USERHOME}#$USERHOME#g" $(brew --prefix)/etc/nginx/ts-dev.conf

    source scripts/ssl.sh
fi

if brew list dnsmasq; then
	echo ""
	echo "Configuring dnsmasq"
	echo ""

	echo 'address=/.localhost/127.0.0.1' > $(brew --prefix)/etc/dnsmasq.conf
	echo 'listen-address=127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
	echo 'port=35353' >> $(brew --prefix)/etc/dnsmasq.conf

	sudo mkdir -pv /etc/resolver
	sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/localhost'
	sudo bash -c 'echo "port 35353" >> /etc/resolver/localhost'
	
	brew services restart dnsmasq
fi
