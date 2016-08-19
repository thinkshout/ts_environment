TS Environment
====================

Sets you up with a server environment on a Mac for Drupal development. If you need examples of how to install common packages with Homebrew, checkout environment_setup.sh

### Requirements:

 - [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12)
 - Xcode command line tools: `xcode-select --install`

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/thinkshout/ts_environment/master/environment_setup.sh)"
```

Once installed you can upgrade your packages to the current stable versions like so:

```
brew update
brew upgrade
```

To enable PHP70 instead of PHP56, run the PHP7_upgrade.sh script then to turn it on and off do the following
```
brew services stop php70 && brew unlink php70 && brew link php56 && brew services start php56 && apachectl -k restart
```

Caveats:

-> After you set up, when you brew update, be very sure you know what Homebrew is telling you when it makes "helpful" suggestions.
