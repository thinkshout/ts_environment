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

echo "Starting setup... which will install your environment or update it."

# Check Homebrew is installed.
brew_installed=`which brew`
if [ "$brew_installed" == "" ] ; then
  echo $'\n'
  echo "Installing Homebrew."
  echo $'\n'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update
  brew doctor
fi

echo "Downloading Homebrew standard bundle."
if [ ! -d ~/ts_environment ] ; then
  git clone https://github.com/thinkshout/ts_environment.git ~/ts_environment
fi

cd ~/ts_environment; git checkout master && git pull

if confirmupdate "Would you like to proceed?"; then
  echo "Starting setup..."
else
  exit
fi

# Install everything in the Brewfile
brew bundle --file=Brewfile

if confirmupdate "Would you like to install local development programs like PHPStorm, Sequel Pro, PHP, MariaDB, etc?"; then
  echo $'\n'
  echo 'Installing local development environment...'

  brew bundle --file=Brewfile-dev

  export PATH=./vendor/bin:~/.composer/vendor/bin:/usr/local/bin:/usr/local/sbin:$PATH

  installed=`ls ~/.oh-my-zsh | grep -i 'oh-my-zsh'`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo ' Installing Oh My ZSH'
    echo $'\n'

    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

    echo "export PATH=./vendor/bin:~/.composer/vendor/bin:/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.zshrc
  fi

  # Configure MariaDB by copying remote config file to local system.
  cp config/ts.cnf $(brew --prefix)/etc/my.cnf.d/ts.cnf
  brew services restart mariadb

  source scripts/nginx.sh

  sudo cp config/co.echo.httpdfwd.plist /Library/LaunchDaemons/
  sudo launchctl load -Fw /Library/LaunchDaemons/co.echo.httpdfwd.plist

  echo $'\n'
  echo "Installing alternate PHP versions (5.6, 7.1)"
  echo $'\n'

  brew unlink php70

  brew install php56
  brew install php56-opcache
  brew install php56-mcrypt
  brew install php56-xdebug
  brew install php56-redis

  brew unlink php56

  brew install php71
  brew install php71-opcache
  brew install php71-mcrypt
  brew install php71-xdebug
  brew install php71-redis

  brew unlink php71
  brew link php70

  echo $'\n'
  echo "Configuring PHP"
  echo $'\n'

  for VER in 5.6 7.0 7.1
  do
    $(brew --prefix gettext)/bin/envsubst < config/php-ts.ini > $(brew --prefix)/etc/php/$VER/conf.d/php-ts.ini
  done

  echo $'\n'
  echo "Starting PHP7 FPM process."
  echo $'\n'
  brew services start php70

  echo $'\n'
  echo "Configuring Frontend tools: Ruby 2.2 using Rbenv"
  echo $'\n'

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

  installed=`which bundler`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo "Installing Bundler"
    echo $'\n'

    ~/.rbenv/shims/gem install bundler
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

  echo $'\n'
  echo "Installing global composer packages (prestissimo, cgr)"
  echo $'\n'

  composer global require -n "hirak/prestissimo:^0.3"
  composer global require -n "consolidation/cgr"

  echo $'\n'
  echo "Dev environment setup complete"
  echo $'\n'

fi

exit
