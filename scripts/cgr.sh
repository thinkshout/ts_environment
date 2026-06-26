#!/bin/bash

export PATH=./vendor/bin:~/.composer/vendor/bin:$PATH

composer global require consolidation/cgr
cgr -W squizlabs/php_codesniffer
cgr -W drupal/coder
cgr -W wp-coding-standards/wpcs
cgr -W consolidation/Robo
cgr -W drush/drush

phpcs --config-set installed_paths ~/.composer/global/drupal/coder/vendor/drupal/coder/coder_sniffer

echo ""
echo "Please ensure that your shell is configured to always include './vendor/bin:~/.composer/vendor/bin' in your PATH"
echo ""
