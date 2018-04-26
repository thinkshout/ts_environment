#!/bin/bash

export PATH=./vendor/bin:~/.composer/vendor/bin:$PATH

composer global require consolidation/cgr
cgr squizlabs/php_codesniffer
cgr drupal/coder
cgr wp-coding-standards/wpcs
cgr pantheon-systems/terminus
cgr consolidation/Robo
cgr drush/drush "^8.0"
cgr drupal/console

echo ""
echo "Please ensure that your shell is configured to always include './vendor/bin:~/.composer/vendor/bin' in your PATH"
echo ""