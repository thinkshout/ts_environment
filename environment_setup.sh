#!/bin/bash

#set -e

confirmupdate () {
  read -r -p "$1 [y/n]" response
  case $response in
    [yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

xcode_path=`xcode-select -p`
echo ""
echo "Sets up the standard ThinkShout development environment."
echo ""
echo "There's no UNDO for this script, so please double check the prereqs now:"
echo "- Required: OSX 10.10 Yosemite or higher"
echo "- Required: An active internet connection"
echo ""

if ! confirmupdate "Would you like to proceed?"; then
  exit
fi

if confirmupdate "Would you like to install desktop programs like PHPStorm, Sequel Pro, and Chrome?"; then
  confirm_cask=true;
else
  confirm_cask=false;
fi

echo "Starting setup... which will install your environment or update it."

# Check Homebrew is installed.
brew_installed=`which brew`
if [ "$brew_installed" == "" ] ; then
  echo $'\n'
  echo "Installing Homebrew."
  echo $'\n'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Updating Homebrew"
  echo $'\n'

  brew update
fi

brew_result=`brew doctor`

if [ "$brew_result" != "Your system is ready to brew." ]; then
  echo "Homebrew was not successful."
  echo "$brew_result"
  if confirmupdate "Would you like to proceed?"; then
      echo "Starting setup..."
    else
      exit
  fi
fi

brew tap homebrew/dupes
brew tap homebrew/homebrew-php
brew tap homebrew/versions
brew tap homebrew/services

installed=`brew ls --versions git`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing git"
  echo $'\n'

  brew install git
fi

installed=`which hub`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Hub"
  echo $'\n'

  brew install hub
fi

installed=`brew ls --versions wget`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing wget"
  echo $'\n'

  brew install wget
fi

installed=`brew ls --versions mysql`
if [ "$installed" == "" ] ; then
  installed=`brew ls --versions mariadb`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo "Installing MySQL"
    echo $'\n'

    brew install mysql

    cp -v $(brew --prefix mysql)/support-files/my-default.cnf $(brew --prefix)/etc/my.cnf

    cat >> $(brew --prefix)/etc/my.cnf <<'EOF'

# Echo & Co. changes
max_allowed_packet = 1073741824
innodb_file_per_table = 1
EOF

    sed -i '' 's/^#[[:space:]]*\(innodb_buffer_pool_size\)/\1/' $(brew --prefix)/etc/my.cnf

    brew services start mysql
  fi
fi

installed=`brew ls --versions httpd22`
if [ "$installed" == "" ] ; then
  installed=`brew ls --versions httpd24`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo "Installing Apache"
    echo $'\n'

    sudo launchctl unload /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null

    brew install apr
    #Hack around httpd formula bug with brewed apr
    ln -s /usr/local/Cellar/apr/1.5.2_1/ /usr/local/Cellar/apr/1.5.2

    brew install homebrew/apache/httpd24 --with-brewed-openssl --with-mpm-event
    brew install homebrew/apache/mod_fastcgi --with-homebrew-httpd24

    sed -i '' '/fastcgi_module/d' $(brew --prefix)/etc/apache2/2.4/httpd.conf

    sed -i '' 's/^#[[:space:]]*\(LoadModule\ ssl_module\)/\1/' $(brew --prefix)/etc/apache2/2.4/httpd.conf
    sed -i '' 's/^#[[:space:]]*\(LoadModule\ vhost_alias_module\)/\1/' $(brew --prefix)/etc/apache2/2.4/httpd.conf
    sed -i '' 's/^#[[:space:]]*\(LoadModule\ actions_module\)/\1/' $(brew --prefix)/etc/apache2/2.4/httpd.conf
    sed -i '' 's/^#[[:space:]]*\(LoadModule\ rewrite_module\)/\1/' $(brew --prefix)/etc/apache2/2.4/httpd.conf

    [ ! -d ~/Sites ] && mkdir -pv ~/Sites

    mkdir -pv ~/Sites/{logs,ssl}

    touch ~/Sites/httpd-vhosts.conf

    (export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; export MODFASTCGIPREFIX=$(brew --prefix mod_fastcgi) ; cat >> $(brew --prefix)/etc/apache2/2.4/httpd.conf <<EOF
 
# Echo & Co. changes
 
# Load PHP-FPM via mod_fastcgi
LoadModule fastcgi_module    ${MODFASTCGIPREFIX}/libexec/mod_fastcgi.so
 
<IfModule fastcgi_module>
  FastCgiConfig -maxClassProcesses 1 -idle-timeout 1500
 
  # Prevent accessing FastCGI alias paths directly
  <LocationMatch "^/fastcgi">
    <IfModule mod_authz_core.c>
      Require env REDIRECT_STATUS
    </IfModule>
    <IfModule !mod_authz_core.c>
      Order Deny,Allow
      Deny from All
      Allow from env=REDIRECT_STATUS
    </IfModule>
  </LocationMatch>
 
  FastCgiExternalServer /php-fpm -host 127.0.0.1:9000 -pass-header Authorization -idle-timeout 1500
  ScriptAlias /fastcgiphp /php-fpm
  Action php-fastcgi /fastcgiphp
 
  # Send PHP extensions to PHP-FPM
  AddHandler php-fastcgi .php
 
  # PHP options
  AddType text/html .php
  AddType application/x-httpd-php .php
  DirectoryIndex index.php index.html
</IfModule>
 
# Include our VirtualHosts
Include ${USERHOME}/Sites/httpd-vhosts.conf
EOF
    )

    (export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; cat > ~/Sites/httpd-vhosts.conf <<EOF
#
# Listening ports.

#Listen 8080  # defined in main httpd.conf
Listen 8443

#
# Set up permissions for VirtualHosts in ~/Sites
#
<Directory "${USERHOME}/Sites">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <IfModule mod_authz_core.c>
        Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </IfModule>
</Directory>

# For http://localhost in the users' Sites folder
<VirtualHost _default_:8080>
    ServerName localhost
    DocumentRoot "${USERHOME}/Sites"
</VirtualHost>
<VirtualHost _default_:8443>
    ServerName localhost
    Include "${USERHOME}/Sites/ssl/ssl-shared-cert.inc"
    DocumentRoot "${USERHOME}/Sites"
</VirtualHost>

#
# VirtualHosts
#

## Manual VirtualHost template for HTTP and HTTPS
#<VirtualHost *:8080>
#  ServerName project.dev
#  CustomLog "${USERHOME}/Sites/logs/project.dev-access_log" combined
#  ErrorLog "${USERHOME}/Sites/logs/project.dev-error_log"
#  DocumentRoot "${USERHOME}/Sites/project.dev"
#</VirtualHost>
#<VirtualHost *:8443>
#  ServerName project.dev
#  Include "${USERHOME}/Sites/ssl/ssl-shared-cert.inc"
#  CustomLog "${USERHOME}/Sites/logs/project.dev-access_log" combined
#  ErrorLog "${USERHOME}/Sites/logs/project.dev-error_log"
#  DocumentRoot "${USERHOME}/Sites/project.dev"
#</VirtualHost>

#
# Automatic VirtualHosts
#
# A directory at ${USERHOME}/Sites/webroot can be accessed at http://webroot.dev
# In Drupal, uncomment the line with: RewriteBase /
#

# This log format will display the per-virtual-host as the first field followed by a typical log line
LogFormat "%V %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combinedmassvhost

# Auto-VirtualHosts with .dev
<VirtualHost *:8080>
  ServerName dev
  ServerAlias *.dev

  CustomLog "${USERHOME}/Sites/logs/dev-access_log" combinedmassvhost
  ErrorLog "${USERHOME}/Sites/logs/dev-error_log"

  VirtualDocumentRoot ${USERHOME}/Sites/%-2+
</VirtualHost>
<VirtualHost *:8443>
  ServerName dev
  ServerAlias *.dev
  Include "${USERHOME}/Sites/ssl/ssl-shared-cert.inc"

  CustomLog "${USERHOME}/Sites/logs/dev-access_log" combinedmassvhost
  ErrorLog "${USERHOME}/Sites/logs/dev-error_log"

  VirtualDocumentRoot ${USERHOME}/Sites/%-2+
</VirtualHost>
EOF
    )

    (export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; cat > ~/Sites/ssl/ssl-shared-cert.inc <<EOF
SSLEngine On
SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW
SSLCertificateFile "${USERHOME}/Sites/ssl/selfsigned.crt"
SSLCertificateKeyFile "${USERHOME}/Sites/ssl/private.key"
EOF
    )

    openssl req \
      -new \
      -newkey rsa:2048 \
      -days 3650 \
      -nodes \
      -x509 \
      -subj "/C=US/ST=State/L=City/O=Organization/OU=$(whoami)/CN=*.dev" \
      -keyout ~/Sites/ssl/private.key \
      -out ~/Sites/ssl/selfsigned.crt

    brew services start httpd24

    sudo bash -c 'export TAB=$'"'"'\t'"'"'
cat > /Library/LaunchDaemons/co.echo.httpdfwd.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
${TAB}<key>Label</key>
${TAB}<string>co.echo.httpdfwd</string>
${TAB}<key>ProgramArguments</key>
${TAB}<array>
${TAB}${TAB}<string>sh</string>
${TAB}${TAB}<string>-c</string>
${TAB}${TAB}<string>echo "rdr pass proto tcp from any to any port {80,8080} -> 127.0.0.1 port 8080" | pfctl -a "com.apple/260.HttpFwdFirewall" -Ef - &amp;&amp; echo "rdr pass proto tcp from any to any port {443,8443} -> 127.0.0.1 port 8443" | pfctl -a "com.apple/261.HttpFwdFirewall" -Ef - &amp;&amp; sysctl -w net.inet.ip.forwarding=1</string>
${TAB}</array>
${TAB}<key>RunAtLoad</key>
${TAB}<true/>
${TAB}<key>UserName</key>
${TAB}<string>root</string>
</dict>
</plist>
EOF'

    sudo launchctl load -Fw /Library/LaunchDaemons/co.echo.httpdfwd.plist
  fi
fi

installed=`brew ls --versions php55`
if [ "$installed" != "" ] ; then
  brew unlink php55
fi

installed=`brew ls --versions php56`
if [ "$installed" == "" ] ; then
  installed=`brew ls --versions php70`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo "Installing PHP"
    echo $'\n'

    brew install homebrew/php/php56

    (export USERHOME=$(dscl . -read /Users/`whoami` NFSHomeDirectory | awk -F"\: " '{print $2}') ; sed -i '-default' -e 's|^;\(date\.timezone[[:space:]]*=\).*|\1 \"'$(sudo systemsetup -gettimezone|awk -F"\: " '{print $2}')'\"|; s|^\(memory_limit[[:space:]]*=\).*|\1 512M|; s|^\(post_max_size[[:space:]]*=\).*|\1 200M|; s|^\(upload_max_filesize[[:space:]]*=\).*|\1 100M|; s|^\(default_socket_timeout[[:space:]]*=\).*|\1 600|; s|^\(max_execution_time[[:space:]]*=\).*|\1 300|; s|^\(max_input_time[[:space:]]*=\).*|\1 600|; $a\'$'\n''\'$'\n''; PHP Error log\'$'\n''error_log = '$USERHOME'/Sites/logs/php-error_log'$'\n' $(brew --prefix)/etc/php/5.6/php.ini)

    chmod -R ug+w $(brew --prefix php56)/lib/php

    brew install php56-opcache

    /usr/bin/sed -i '' "s|^\(\;\)\{0,1\}[[:space:]]*\(opcache\.enable[[:space:]]*=[[:space:]]*\)0|\21|; s|^;\(opcache\.memory_consumption[[:space:]]*=[[:space:]]*\)[0-9]*|\1256|;" $(brew --prefix)/etc/php/5.6/php.ini

    brew services start php56
  fi
fi

installed=`brew ls --versions dnsmasq`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Dnsmasq"
  echo $'\n'

  brew install dnsmasq

  echo 'address=/.dev/127.0.0.1' > $(brew --prefix)/etc/dnsmasq.conf
  echo 'listen-address=127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
  echo 'port=35353' >> $(brew --prefix)/etc/dnsmasq.conf

  brew services start dnsmasq

  sudo mkdir -v /etc/resolver
  sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dev'
  sudo bash -c 'echo "port 35353" >> /etc/resolver/dev'
fi

installed=`brew ls --versions drush`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Drush"
  echo $'\n'

  brew install drush
fi

installed=`brew ls --versions drupalconsole`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Drupal Console"
  echo $'\n'

  brew install drupalconsole
fi

installed=`which terminus`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Terminus"
  echo $'\n'

  brew install terminus
fi

installed=`brew ls --versions composer`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Composer"
  echo $'\n'

  brew install composer
  echo "export PATH=~/.composer/vendor/bin:$PATH" >> ~/.zshrc
fi

installed=`brew ls --versions php56-xdebug`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Xdebug"
  echo $'\n'

  brew install php56-xdebug

  echo $'\n'
  echo "Adding Xdebug configuration to php.ini (php 5.6)"
  echo $'\n'

  cat >> $(brew --prefix)/etc/php/5.6/php.ini <<EOF
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
fi

installed=`brew ls --versions drupal-code-sniffer`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Drupal Code Sniffer"
  echo $'\n'

  brew install drupal-code-sniffer
fi

installed=`brew ls --versions rbenv`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Frontend tools: Ruby 2.2 using Rbenv"
  echo $'\n'

  brew install rbenv ruby-build
  if [ -n "$ZSH_VERSION" ]; then
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi'>> ~/.zshrc
    source ~/.zshrc
  elif [ -n "$BASH_VERSION" ]; then
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi'>> ~/.bashrc
    source ~/.bashrc
  else
     echo $'\n'
     echo $'Failed to install Rbenv. Please rbenv init for your shell. Sorry.'
     echo $'\n'
  fi
  rbenv install 2.2.2
  rbenv global 2.2.2
fi

installed=`which bundler`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo "Installing Bundler"
  echo $'\n'

  ~/.rbenv/shims/gem install bundler
fi

installed=`which npm`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo 'Installing NPM'
  echo $'\n'

  brew install npm;npm install -g npm@latest;
fi

installed=`which grunt`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo 'Installing Grunt'
  echo $'\n'
  npm install -g grunt-cli
fi

installed=`which gulp`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo 'Installing gulp'
  echo $'\n'
  npm install --global gulp-cli
fi

installed=`which compass`
if [ "$installed" == "" ] ; then
  echo $'\n'
  echo 'Installing Compass'
  echo $'\n'

  ~/.rbenv/shims/gem install compass
fi

if [ "$confirm_cask" == true ] ; then
  echo $'\n'
  echo 'Installing any additional desktop applications...'

  brew tap caskroom/cask

  installed=`ls /Applications/ | grep -i Google\ Chrome`
  if [ "$installed" == "" ] ; then
    installed=`ls ~/Applications/ | grep -i Google\ Chrome`
    if [ "$installed" == "" ] ; then

      echo $'\n'
      echo 'Installing Google Chrome'
      echo $'\n'

      brew cask install google-chrome
    fi
  fi

    installed=`ls /Applications/ | grep -i Firefox`
  if [ "$installed" == "" ] ; then
    installed=`ls ~/Applications/ | grep -i Firefox`
    if [ "$installed" == "" ] ; then

      echo $'\n'
      echo 'Installing Firefox'
      echo $'\n'

      brew cask install firefox
    fi
  fi

  installed=`ls /Applications/ | grep -i Slack`
  if [ "$installed" == "" ] ; then
    installed=`ls ~/Applications/ | grep -i Slack`
    if [ "$installed" == "" ] ; then

      echo $'\n'
      echo 'Installing Slack'
      echo $'\n'

      brew cask install slack
    fi
  fi

  installed=`ls /Applications/ | grep -i iTerm`
  if [ "$installed" == "" ] ; then
    installed=`ls ~/Applications/ | grep -i iTerm`
    if [ "$installed" == "" ] ; then

      echo $'\n'
      echo 'Installing iTerm2'
      echo $'\n'

      brew cask install iterm2
    fi
  fi

  installed=`ls /Applications/ | grep -i 'Sequel Pro'`
  if [ "$installed" == "" ] ; then
    installed=`ls ~/Applications/ | grep -i 'Sequel Pro'`
    if [ "$installed" == "" ] ; then

      echo $'\n'
      echo 'Installing Sequel Pro'
      echo $'\n'

      brew cask install sequel-pro
    fi
  fi

  installed=`ls /Applications/ | grep -i PhpStorm`
  if [ "$installed" == "" ] ; then
    installed=`ls ~/Applications/ | grep -i PhpStorm`
    if [ "$installed" == "" ] ; then

      echo $'\n'
      echo 'Installing PhpStorm'
      echo $'\n'

      brew cask install phpstorm
    fi
  fi

  installed=`ls /Applications/ | grep -i 1Password`
  if [ "$installed" == "" ] ; then
    installed=`ls ~/Applications/ | grep -i 1Password`
    if [ "$installed" == "" ] ; then

      echo $'\n'
      echo 'Installing 1Password'
      echo $'\n'

      brew cask install 1password
    fi
  fi

  installed=`which zsh`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo "Installing ZSH"
    echo $'\n'

    brew install zsh
  fi

  installed=`ls ~/.oh-my-zsh | grep -i 'oh-my-zsh'`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo ' Installing Oh My ZSH'
    echo $'\n'

    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
  fi

  installed=`which ngrok`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo "Installing ngrok"
    echo $'\n'

    brew cask install ngrok
  fi

  installed=`ls /Applications/ | grep -i 'Adobe Creative Cloud'`
  if [ "$installed" == "" ] ; then

    echo $'\n'
    echo 'Installing Adobe Creative Cloud'
    echo $'\n'

    brew cask install adobe-creative-cloud
    open  /opt/homebrew-cask/Caskroom/adobe-creative-cloud/latest/Creative\ Cloud\ Installer.app
  fi
fi

echo $'\n'
echo "Dev environment setup complete"
echo $'\n'

exit
