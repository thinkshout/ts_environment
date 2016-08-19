# Set current and new version variables.
currentVersion="`php -r \"error_reporting(0); echo str_replace('.', '', substr(phpversion(), 0, 3));\"`"
newVersion="70"
newDotVersion="7.0"
shortOld="`php -r \"error_reporting(0); echo substr(phpversion(), 0, 1);\"`"
shortNew="`php -r \"error_reporting(0); echo substr('${newVersion}', 0, 1);\"`"

# If php70 is already current version, exit.
if [ ${currentVersion} -eq ${newVersion} ]; then
  echo "php${newVersion} is alredy your current version"
  exit 0;
fi

# Install php70 if it is not already.
brew list php${newVersion} 2> /dev/null > /dev/null
if [ $? -eq 1 ]; then
  brew unlink php${currentVersion}
  brew install php${newVersion}
  echo "Linking new modphp addon..."
  sudo ln -sf `brew list php${newVersion} | grep libphp` $(brew --prefix)/lib/libphp${shortNew}.so
# Unlink current php and link php70.
else
  echo "Unlinking old ${currentVersion} binaries...\n"
  brew unlink php${currentVersion} 2> /dev/null > /dev/null
  echo "Linking new ${newVersion} binaries..."
  brew link php${newVersion}
  echo "Linking new modphp addon..."
  sudo ln -sf `brew list php${newVersion} | grep libphp` $(brew --prefix)/lib/libphp${shortNew}.so
fi

# Install xdebug for php70 if it is not already.
brew list php${newVersion}-xdebug 2> /dev/null > /dev/null
if [ $? -eq 1 ]; then
  brew install php${newVersion}-xdebug
fi

echo "Updating general PHP settings...\n"
sed -i -e "s|^;\(date\.timezone[[:space:]]*=\).*|\1 \"$(sudo systemsetup -gettimezone|awk -F": " '{print $2}')\"|; s|^\(post_max_size[[:space:]]*=\).*|\1 200M|; s|^\(upload_max_filesize[[:space:]]*=\).*|\1 100M|; s|^\(default_socket_timeout[[:space:]]*=\).*|\1 600|; s|^\(max_execution_time[[:space:]]*=\).*|\1 300|; s|^\(max_input_time[[:space:]]*=\).*|\1 600|;" $(brew --prefix)/etc/php/${newDotVersion}/php.ini

echo "Updating opcache settings...\n"
sed -i -e "s|^\(\;\)\{0,1\}[[:space:]]*\(opcache\.enable[[:space:]]*=[[:space:]]*\)0|\21|; s|^;\(opcache\.memory_consumption[[:space:]]*=[[:space:]]*\)[0-9]*|\1256|;" $(brew --prefix)/etc/php/${newDotVersion}/php.ini

echo "Setting PHP error log location...\n"
USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F": " '{print $2}') cat >> $(brew --prefix)/etc/php/${newDotVersion}/php.ini <<EOF

; PHP error log location.
error_log = ${USERHOME}/Sites/logs/php-error_log
EOF

echo "Adding xdebug settings to php.ini...\n"
cat >> $(brew --prefix)/etc/php/${newDotVersion}/php.ini <<EOF

[xdebug]
xdebug.default_enable=1
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_host=localhost
xdebug.remote_port=9001
xdebug.remote_autostart=1
; Needed for Drupal 8
xdebug.max_nesting_level = 256
EOF

echo "DONE!!! You're upgraded to php70!"
