TS Environment
====================

Sets you up with a server environment on a Mac for Drupal development. If you need examples of how to install common packages with Homebrew, checkout environment_setup.sh

### Getting Started:
```
cd ~
xcode-select --install
git clone git@github.com:thinkshout/ts_environment.git
cd ts_environment
./environment_setup.sh
```

Once installed you can upgrade your packages to the current stable versions like so:

```
brew update
brew upgrade
```

### Manual steps:

After installing development tools, you'll need to set the password for MariaDB:
```
sudo mysql_secure_installation
```
Set login to root and password to root and answer yes to all the questions in the wizard.


### Switching PHP versions

You can switch php version using the `sphp` command. Examples:

PHP - 7.1:
```
sphp 7.1
```

PHP to the latest version (the one supported by homebrew):
```
sphp X.X # Where X.X is the current version of php.
```

Caveats:

* Be careful when running `brew upgrade` - sometimes formulas can change, and your environment may change or break in subtle ways.
* Be prepared to deal with `brew upgrade` fallout, and update only when necessary, or at a low-risk time.
* Be very sure you know what Homebrew is telling you when it makes "helpful" suggestions.

### PHP Coding Standards

This script no longer installs php-code-sniffer. Install and configure it using the following:

1. install via homebrew:

~~~bash
brew install php-code-sniffer
~~~

2. Verify that you see coding standards:

~~~bash
phpcs -i
The installed coding standards are MySource, PEAR, PSR1, PSR12, PSR2, Squiz, and Zend
~~~

3. Create a local `Standards` folder to add symlinks to the Drupal and WP coding standards:

~~~bash
mkdir php-code-sniffer;mkdir php-code-sniffer/Standards;cd php-code-sniffer/Standards
~~~

4. Create symlinks to your Composer-installed standards:

~~~bash
ln -s ~/.composer/global/drupal/coder/vendor/drupal/coder/coder_sniffer/Drupal Drupal
ln -s ~/.composer/global/wp-coding-standards/wpcs/vendor/wp-coding-standards/wpcs/WordPress-Core WordPress-Core
~~~

5. Verify that you see coding the updated standards:

~~~bash
phpcs -i
The installed coding standards are MySource, PEAR, PSR1, PSR12, PSR2, Squiz, Zend, Drupal and WordPress-Core
~~~

6. Configure PHPstorm to use the correct version of Codesniffer:

- open PHPstorm and go to the Preferences screen
- go to "Languages & Frameworks" -> "PHP" -> "Code Sniffer"
- click the "..." next to the configuration and validate

7. Configure PHPstorm to use Codesniffer's Drupal Standards:

- in PHPstorm preferences, go to "Editor" -> "Inspections"
- in the settings tree on the right, find "PHP" -> "PHP Code Sniffer validation" and select it
- All the way on the right, find the "Code Sniffing Standards" drop-down and select "Drupal"
