#!/bin/bash

export PATH=./vendor/bin:~/.composer/vendor/bin:$PATH

composer global require consolidation/cgr
cgr squizlabs/php_codesniffer "^2.9"
cgr drupal/coder
cgr wp-coding-standards/wpcs
cgr consolidation/Robo
cgr drush/drush "^8.0"
cgr drupal/console

phpcs --config-set installed_paths ~/.composer/global/drupal/coder/vendor/drupal/coder/coder_sniffer

echo ""
echo "Please ensure that your shell is configured to always include './vendor/bin:~/.composer/vendor/bin' in your PATH"
echo ""
