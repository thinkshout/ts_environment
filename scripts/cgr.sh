#!/bin/bash

export PATH=./vendor/bin:~/.composer/vendor/bin:$PATH

composer global require consolidation/cgr

cgr squizlabs/php_codesniffer "^2.9"
cgr drupal/coder
cgr wp-coding-standards/wpcs
cgr pantheon-systems/terminus
cgr consolidation/Robo
cgr drush/drush "^8.0"
cgr drupal/console

ln -s ~/.composer/global/drupal/coder/vendor/drupal/coder/coder_sniffer/Drupal $(brew --prefix)/etc/php-code-sniffer/Standards/
ln -s ~/.composer/global/drupal/coder/vendor/drupal/coder/coder_sniffer/DrupalPractice $(brew --prefix)/etc/php-code-sniffer/Standards/

ln -s ~/.composer/global/wp-coding-standards/wpcs/vendor/wp-coding-standards/wpcs/WordPress $(brew --prefix)/etc/php-code-sniffer/Standards/
ln -s ~/.composer/global/wp-coding-standards/wpcs/vendor/wp-coding-standards/wpcs/WordPress-Core $(brew --prefix)/etc/php-code-sniffer/Standards/
ln -s ~/.composer/global/wp-coding-standards/wpcs/vendor/wp-coding-standards/wpcs/WordPress-Docs $(brew --prefix)/etc/php-code-sniffer/Standards/
ln -s ~/.composer/global/wp-coding-standards/wpcs/vendor/wp-coding-standards/wpcs/WordPress-Extra $(brew --prefix)/etc/php-code-sniffer/Standards/
ln -s ~/.composer/global/wp-coding-standards/wpcs/vendor/wp-coding-standards/wpcs/WordPress-VIP $(brew --prefix)/etc/php-code-sniffer/Standards/

echo ""
echo "Please ensure that your shell is configured to always include './vendor/bin:~/.composer/vendor/bin' in your PATH"
echo ""
