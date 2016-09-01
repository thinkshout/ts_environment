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

### Switching PHP versions

Apache - 5.6 to 7.0:
```
brew services stop php56;brew services start php70
```

Apache - 7.0 to 5.6:
```
brew services stop php70;brew services start php56
```

Switching CLI version of PHP:
```
brew unlink php56;brew link php70
```

Caveats:

-> After you set up, when you brew update, be very sure you know what Homebrew is telling you when it makes "helpful" suggestions.
