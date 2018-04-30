TS Environment
====================

Sets you up with a server environment on a Mac for Drupal development. If you need examples of how to install common packages with Homebrew, checkout environment_setup.sh

### Requirements:

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

PHP - 5.6 to 7.0:
```
brew services stop php@5.6; brew services start php@7.0
```

PHP - 7.0 to 5.6:
```
brew services stop php@7.0; brew services start php@5.6
```

Switching CLI version of PHP:
```
brew unlink php@5.6; brew link php@7.0 --force
```

Caveats:

* Be careful when running `brew upgrade` - sometimes formulas can change, and your environment may change or break in subtle ways.
* Be prepared to deal with `brew upgrade` fallout, and update only when necessary, or at a low-risk time.
* Be very sure you know what Homebrew is telling you when it makes "helpful" suggestions.

### PHP Coding Standards

This script installs php-code-sniffer, but configuration is not working as of September 2017. To work around this:

1. Remove any existing version of drupal-coding-standards from homebrew:

$ brew uninstall drupal-coding-standards

Note that coder is now installed via composer (cgr actually) in your home directory, at ~/.composer/global/drupal/coder/vendor/drupal/coder

4. Find your config folder for PHP CS standards. It's called "installed_paths"

$ phpcs --config-show

<example output>
Using config file: /usr/local/Cellar/php-code-sniffer/3.1.0/CodeSniffer.conf

installed_paths: /usr/local/etc/php-code-sniffer/Standards
</example output>

5. Go to your Standards folder

$ cd /usr/local/etc/php-code-sniffer/Standards

6. Create a symlink to your Composer-installed standards:

$ ln -s ~/.composer/global/drupal/coder/vendor/drupal/coder/coder_sniffer/Drupal Drupal

7. Configure PHPstorm to use the correct version of Codesniffer:

- open PHPstorm and go to the Preferences screen
- go to "Languages & Frameworks" -> "PHP" -> "Code Sniffer"
- click the "..." next to the configuration and validate

8. Configure PHPstorm to use Codesniffer's Drupal Standards:

- in PHPstorm preferences, go to "Editor" -> "Inspections"
- in the settings tree on the right, find "PHP" -> "PHP Code Sniffer validation" and select it
- All the way on the right, find the "Code Sniffing Standards" drop-down and select "Drupal"
