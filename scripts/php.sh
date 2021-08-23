#!/bin/bash

if brew list php; then
  echo $'\n'
  echo "Configuring PHP"
  echo $'\n'

  echo $'\n'
  echo "Installing PECL extensions (xdebug) for each version of PHP"
  echo $'\n'

  brew unlink php

  for VER in 7.3 7.4 8.0
  do
    brew link --force php@$VER
    php -v
    pecl install -f xdebug
    brew unlink php@$VER
  done

  echo $'\n'
  echo "Installing TS config for each version of PHP"
  echo $'\n'

  for VER in 7.3 7.4 8.0
  do
    $(brew --prefix gettext)/bin/envsubst < config/php-ts.ini > $(brew --prefix)/etc/php/$VER/conf.d/php-ts.ini
  done

  # Install cgr scripts under oldest php version for backwards compat
  brew unlink php
  brew link --force php@7.3

  source scripts/cgr.sh

  brew unlink php@7.3

  echo $'\n'
  echo "Starting PHP."
  echo $'\n'

  brew link php
  brew services start php

  mkdir -pv ~/.drush
  cp -n config/drushrc.php ~/.drush/drushrc.php
fi
