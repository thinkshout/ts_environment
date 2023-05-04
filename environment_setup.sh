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
echo "- Required: OSX 10.15 Catalina or higher"
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
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Check for non intel mac
  is_m1=`which brew`
  if [ "$is_m1" == "/opt/homebrew/bin/brew" ] ; then
   eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew update
  brew doctor
fi

echo "Downloading Homebrew standard bundle."
if [ ! -d ~/ts_environment ] ; then
  git clone https://github.com/thinkshout/ts_environment.git ~/ts_environment
fi

cd ~/ts_environment; git checkout main && git pull

if confirmupdate "Would you like to proceed?"; then
  echo "Starting setup..."
else
  exit
fi

# Install everything in the Brewfile
brew bundle --file=Brewfile

if confirmupdate "Would you like to install local development programs like PHPStorm, Sequel Ace, PHP, MariaDB, etc?"; then
  echo $'\n'
  echo 'Installing local development environment...'

  brew bundle --file=Brewfile-dev

  # Set some standard git configuration
  git config --global pull.rebase true

  export PATH=./vendor/bin:~/.composer/vendor/bin:/usr/local/bin:/usr/local/sbin:$PATH

  installed=`ls ~/.oh-my-zsh | grep -i 'oh-my-zsh'`
  if [ "$installed" == "" ] ; then
    echo $'\n'
    echo ' Installing Oh My ZSH'
    echo $'\n'

    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

    echo "export PATH=./vendor/bin:~/.composer/vendor/bin:/usr/local/bin:/usr/local/sbin:$PATH" >> ~/.zshrc

    mkdir -pv ~/.oh-my-zsh/custom
    cp config/ts.zsh ~/.oh-my-zsh/custom/ts.zsh
    
    is_m1=`which brew`
    if [ "$is_m1" == "/opt/homebrew/bin/brew" ] ; then
      (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

  # Configure MariaDB by copying remote config file to local system.
  cp config/ts.cnf $(brew --prefix)/etc/my.cnf.d/ts.cnf
  brew services restart mariadb

  source scripts/nginx.sh

  sudo cp config/co.echo.httpdfwd.plist /Library/LaunchDaemons/
  sudo launchctl load -Fw /Library/LaunchDaemons/co.echo.httpdfwd.plist

  source scripts/php.sh

  echo $'\n'
  echo "Configuring Frontend tools with Ruby and Rbenv"
  echo $'\n'

  echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi'>> ~/.zshrc
  echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi'>> ~/.bashrc

  rbenv install 2.6.5
  rbenv global 2.6.5

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
  echo "Dev environment setup complete"
  echo $'\n'

fi

exit
