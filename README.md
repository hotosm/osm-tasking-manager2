# OpenStreetMap Tasking Manager

[![Build Status](https://travis-ci.org/hotosm/osm-tasking-manager2.svg?branch=master)](https://travis-ci.org/hotosm/osm-tasking-manager2)
[![Coverage Status](https://coveralls.io/repos/hotosm/osm-tasking-manager2/badge.png?branch=master)](https://coveralls.io/r/hotosm/osm-tasking-manager2?branch=master)

## About

OSMTM enables collaborative work on specific areas in OpenStreetMap by defining
clear workflows to be achieved and by breaking tasks down into pieces.

The application is written in Python using the Pyramid framework.

This is the 2.0 version of the Tasking Manager.

## Installation

First clone the git repository:

    git clone --recursive git://github.com/hotosm/osm-tasking-manager2.git

Installing OSMTM in a Virtual Python environment is recommended.

To create a virtual Python environment:

    cd osm-tasking-manager2
    sudo easy_install virtualenv
    virtualenv --no-site-packages env
    ./env/bin/python setup.py develop

*Tip: if you encounter problems installing `psycopg2` especially on Mac, it is recommended to follow advice proposed [here](http://stackoverflow.com/questions/22313407/clang-error-unknown-argument-mno-fused-madd-python-package-installation-fa).*

### Database

OSMTM requires a PostgreSQL/PostGIS database. Version 2.x of PostGIS is
required.

First create a database user/role named `www-data`:

    sudo -u postgres createuser -SDRP www-data

Then create a database named `osmtm`:

    sudo -u postgres createdb -O www-data osmtm
    sudo -u postgres psql -d osmtm -c "CREATE EXTENSION postgis;"

### Local settings

You certainly will need some local specific settings, like the db user or
password. For this, you can create a `local.ini` file in the project root,
where you can then override every needed setting.
For example:

    [app:main]
    sqlalchemy.url = postgresql://www-data:www-data@localhost/osmtm

Note: you can also put your local settings file anywhere else on your
file system, and then create a `LOCAL_SETTINGS_PATH` environment variable
to make the project aware of this.

### Populate the database

You're now ready to do the initial population of the database. An
`initialize_osmtm_db` script is available in the virtual env for that:

    ./env/bin/initialize_osmtm_db

### Launch the application

    ./env/bin/pserve --reload development.ini

You will see messages, hopefully including a line like `serving on http://0.0.0.0:6543`.
Visit that address in your web browser - you should see your local Tasking Manager!


### Styles

The CSS stylesheet are compiled using less. Launch the following command as
soon as you change the css:

    lessc -ru osmtm/static/css/main.less > osmtm/static/css/main.css

## Launch the application

    env/bin/pserve --reload development.ini

## Tests

The tests use a separate database. Create that database first:

    sudo -u postgres createdb -O www-data osmtm_tests
    sudo -u postgres psql -d osmtm_tests -c "CREATE EXTENSION postgis;"

Create a `local.test.ini`file in the project root, where you will add the
settings for the database connection.
For example:

    [app:main]
    sqlalchemy.url = postgresql://www-data:www-data@localhost/osmtm_tests

To run the tests, use the following command:

    ./env/bin/nosetests

## Application deployment

1. pull latest updates from the repository: `git pull origin`
1. update the submodules: `git submodule update`
1. update/install python modules: `python setup.py develop`
1. create database dump: `pg_dump -Fc -f osmtm2_latest.dmp database_name`
1. run database migrations: `alembic upgrade head`
1. compile messages: `python setup.py compile_catalog`
1. restart application server


## Customization

In case you install your own instance you may want to customize its look and
feel. You can do so by modifying the following files:
`osmtm/templates/custom.mako`, `osmtm/static/css/custom.less` &
`osmtm/static/img/favicon.ico`

## Localization

OSMTM is localized on [https://www.transifex.com/projects/p/osm-tasking-manager2/](Transifex) service.

It's possible to create translations for two resources: **current** and
**master**. *Current* resource represents currently deployed instance of the
OSMTM [http://tasks.hotosm.org](). *Master* resource represents actively
developed code that will become *current* once it gets deployed.

### Initializing translation files

In general managing translation files involves:

* generate *pot* file: `python setup.py extract_messages`
* initialize a message catalogue file (english): `python setup.py init_catalog -l en`
  * if the catalogue is already created use: `python setup.py update_catalog`
* eventually compile messages: `python setup.py compile_catalog`
* append new language to the `available_languages` configuration variable in *production.ini* file, for example `available_languages = en fr`

### Using Transifex service

* in the project top level directory, initialize transifex service (after installing `transifex-client`): `tx init`
  * the init process will ask for service URL and username/password, which will be saved to `~/.transifexrc` file
* if the project has already been initialized, but you are missing `~/.transifexrc`, create the file and modify it's access privileges `chmod 600 ~/.transifexrc`

Example `.transifexrc` file:

    [https://www.transifex.com]
    hostname = https://www.transifex.com
    password = my_super_password
    token =
    username = my_transifex_username

* after creating the project on the Transifex service: `osm-tasking-manager2`, generate the pot file, and add it as a `master` resource on the project, full resource name, in this case, is `osm-tasking-manager2.master`

#### Setting up resources

* add initial source file, in this case English:
  * `tx set --source -r osm-tasking-manager2.master -l en osmtm/locale/en/LC_MESSAGES/osmtm.po`
* add existing source files, in this case French:
  * `tx set -r osm-tasking-manager2.master -l fr osmtm/locale/fr/LC_MESSAGES/osmtm.po`
* push resources on the transifex service (this will overwrite any existing resources on the service)
  * `tx push -s -t`
  * `-s` - pushes source files (English)
  * `-t` - pushes translation files (French)

#### Pulling changes

* to pull latest changes from Transifex service execute: `tx pull`
  * this will pull every available language from the Transifex service, even the languages that are not yet mapped
  * if the language is not mapped, translated language file will be saved to the local `.tx` directory, which is not what we want so we need to define the mapping
  * for example, if we want to correctly map Croaian language you need to execute: `tx set -r osm-tasking-manager2.master -l hr osmtm/locale/hr/LC_MESSAGES/osmtm.po`
    * there is no need to create the actual po file or the directory structure, Transifex client will manage that for us
* there is also a possibility to pull specific languages: `tx pull -l hr`
* or pull only languages that have a certain completeness percentage: `tx pull --minimum-perc=90`

### Transifex workflow

#### Updating source files, locally and on the service

* update pot and source po file
  * `python setup.py extract_messages`
  * `python setup.py init_catalog -l en`

* push the source file to Transifex service
  * `tx push -s`

#### Pull latest changes from the service

* when adding a new language:
  * we need to configure local mapping: `tx set -r osm-tasking-manager2.master -l hr osmtm/locale/hr/LC_MESSAGES/osmtm.po`
  * append the new language to the `available_languages` configuration variable in *production.ini* file: `available_languages = en fr hr`
* after there are some translation updates, pull latest changes for mapped resources
  * `tx pull -l fr,hr`
* compile language files
  * `python setup.py compile_catalog`
