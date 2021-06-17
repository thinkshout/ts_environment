
# Switch php
# - Stops current php, and starts specified version
# - Depends on homebrew php
#
# Usage - switch to php@7.1:
#  sphp 7.1
#
function sphp() {
  PHP_OFF=$( brew services list | awk '$1~/php/ && $2~/started/ {print $1}' )
  if [ -n "$PHP_OFF" ]; then
    brew services stop "$PHP_OFF"
    brew unlink "$PHP_OFF"
  fi

  PHP_ON="php@$@"
  brew services start "$PHP_ON"
  brew link --force "$PHP_ON"
}

alias composer="COMPOSER_MEMORY_LIMIT=-1 composer"
