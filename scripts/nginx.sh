#!/bin/bash

installed=`which nginx`
if [ "$installed" == "" ] ; then
	echo $'\n'
	echo "Configuring nginx"
	echo $'\n'

	sudo launchctl unload /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null

	[ ! -d ~/Sites ] && mkdir -pv ~/Sites

	export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}')

	$(brew --prefix gettext)/bin/envsubst < ~/ts_environment/config/nginx.conf > $(brew --prefix)/etc/nginx/nginx.conf
	$(brew --prefix gettext)/bin/envsubst < ~/ts_environment/config/ts-dev.conf > $(brew --prefix)/etc/nginx/ts-dev.conf

	mkdir -p $(brew --prefix)/etc/nginx/ssl

	openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=State/L=Town/O=Office/CN=dev" -keyout $(brew --prefix)/etc/nginx/ssl/dev.key -out $(brew --prefix)/etc/nginx/ssl/dev.crt

	brew services start nginx
else
	echo $'\n'
	echo "nginx is not installed - skipping"
	echo $'\n'
fi
