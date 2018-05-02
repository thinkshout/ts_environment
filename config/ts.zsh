
# Switch php
# - Stops current php, and starts specified version
# - Depends on homebrew php
#
# Usage - switch to php@5.6:
#  sphp 5.6
#
function sphp() {
  PHP_OFF=$( brew services list | awk '$1~/php/ && $2~/started/ {print $1}' )
  if [ -n "$PHP_OFF" ]; then
    brew services stop "$PHP_OFF"
    brew unlink "$PHP_OFF"
  fi

  PHP_ON="php@$@"
  brew link --force "$PHP_ON"
  brew services start "$PHP_ON"
}

