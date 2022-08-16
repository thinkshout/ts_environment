
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

# Switch composer
# - Switches to the specified version of composer
#
# Usage - switch to composer 2
#  sc 2
#
function sc() {
  \composer self-update --$@
}

# Required to make nvm work (https://github.com/nvm-sh/nvm#installing-and-updating)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
