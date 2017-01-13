#!/bin/bash

./env/bin/initialize_osmtm_db
./env/bin/pserve --reload development.ini
