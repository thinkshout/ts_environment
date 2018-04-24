#!/bin/bash

if brew list php; then
  echo $'\n'
  echo "Configuring PHP"
  echo $'\n'

  echo $'\n'
  echo "Installing PECL extensions (xdebug) for each version of PHP"
  echo $'\n'
  brew unlink php@7.2
  for VER in 5.6 7.0 7.1 7.2
  do
    brew link --force php@$VER
    php -v
    if [ $VER == '5.6' ]; then
      pecl install -f xdebug-2.5.5
    else
      pecl install -f xdebug
    fi
    brew unlink php@$VER
  done

  brew link php@7.2

  echo $'\n'
  echo "Installing TS config for each version of PHP"
  echo $'\n'
  for VER in 5.6 7.0 7.1 7.2
  do
    $(brew --prefix gettext)/bin/envsubst < config/php-ts.ini > $(brew --prefix)/etc/php/$VER/conf.d/php-ts.ini
  done

  echo $'\n'
  echo "Starting PHP7 FPM process."
  echo $'\n'
  brew services start php
fi
