#Tufts Digital Image Library
[![Build Status](https://travis-ci.org/curationexperts/trove.svg?branch=master)](https://travis-ci.org/curationexperts/trove)

This application was developed for Ruby 2.1.2, which was the most recently released version of Ruby as of Sept 2014.


## Initial Setup for Developers

### Install Dependencies
* install libreoffice which provides the "soffice" executable required for generating powerpoint and PDF exports:
    * ubuntu (or other linux distros; change "apt-get" command as needed)
        * sudo apt-get -y install libreoffice
    * OSX:
        * $ brew tap caskroom/homebrew-cask
        * $ brew install Caskroom/cask/libreoffice
        * Add "soffice" to your path, e.g:
        * ```export PATH=/Users/yourname/Applications/LibreOffice.app/Contents/MacOS:$PATH```
    * The command ```which soffice``` should succeed
    * See also README_poi_setup_notes

### Copy the source code and install gems
* git clone https://github.com/curationexperts/trove.git
* cd trove
* bundle install

### Copy sample config files:
* rake config:copy

### (optional) Replace the ```secret_key_base``` in config/secrets.yml.
* rake secret

* Edit config/secrets.yml
  * Replace the ```secret_key_base``` with a new key, which you can generate with ```rake secret```


### Configure hydra-jetty:
In general you will want a development instance of both MIRA and Trove running using a shared copy of Fedora and Solr to mimic a production environment.  You'll use MIRA to ingest content and edit metadata and Trove to view content and manage collections.

To run a shared copy of hydra-jetty:

* cd to your *mira* directory and install and start hydra-jetty as described in the [MIRA documentation](https://github.com/curationexperts/mira#initial-setup)
* the default versions of the solr, fedora, and redis files copyied from the sample configs are set up to talk to the services on their default ports which were configured automatically when you set up MIRA
* to stop and start jetty, you'll need to cd to your *mira* directory and run `bundle exec rake jetty:stop` and `bundle exec rake jetty:stop` (from the mira directory)

> **NOTE:** If you want to install a stand-alone copy of hydra-jetty and manually populate it with test data
> * rails g hydra:jetty
> * rake jetty:config
> * rake jetty:start

### Share the data directory between MIRA & Trove
If you are running a shared version of Fedora and Solr, you'll want both applications to use the same data store directory.  You can do this by editing the `trove/config/application.yml` file to point to the local_object_store where MIRA saves it's binary uploads.  If *mira* and *trove* are both in subdirectories of the same working directory edit the config/application.yml file and change the development/object_store_root line to read 
```
    object_store_root: "<%=Rails.root%>/../mira/tmp/local_object_store"
```

### Check your installation
Ingest some images into MIRA, mark them for display in trove, and publish them to make them visible in trove.  If you want to have MIRA and Trove running simulaneously you'll need to start one of the servers on an alternat port (instead of the default port 3000).

* rails s -p 3005

Then acccess the server via

* http://localhost:3005

## Specify your featured pids
You can specify featured items or collections on the homepage by editing the feature_data.yml file appropriately

* Edit `config/feature_data.yml` as needed.
