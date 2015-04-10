#Tufts Digital Image Library
[![Build Status](https://travis-ci.org/curationexperts/trove.svg?branch=master)](https://travis-ci.org/curationexperts/trove)

This application was developed for Ruby 2.1.2, which was the most recently released version of Ruby as of Sept 2014.

## Dependencies
* libreoffice for the "soffice" executable:
 * ubuntu (or other linux distros; change "apt-get" command as needed)
  * sudo apt-get -y install libreoffice
 * OSX:
  * $ brew tap caskroom/homebrew-cask
  * $ brew install Caskroom/cask/libreoffice
  * Add "soffice" to your path, e.g:
   * ```export PATH=/Users/yourname/Applications/LibreOffice.app/Contents/MacOS:$PATH```
 * The command ```which soffice``` should succeed
* See also README_poi_setup_notes

## Initial Setup for Developers

* bundle install

### Download & Configure hydra-jetty:
* rails g hydra:jetty
* rake jetty:config
* rake jetty:start

### Copy sample config files:
* rake config:copy

### (optional) Replace the ```secret_key_base``` in config/secrets.yml.
* rake secret

* Edit config/secrets.yml
  * Replace the ```secret_key_base``` with a new key, which you can generate with ```rake secret```

### Specify your featured pids

* Edit ```config/feature_data.yml``` as needed.
