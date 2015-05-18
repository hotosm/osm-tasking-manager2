.PHONY: all
all: install

.PHONY: help
help:
	@echo "Usage: make [command]\n"
	@echo "Commands available:"
	@echo "  install    Setup the virtual environment and app"
	@echo "  setup      Setup the app"
	@echo "  env        Setup the virtual environment"

.PHONY: install
install: env setup

.PHONY: setup
setup:
	env/bin/python setup.py develop

.PHONY: env
env:
	virtualenv --no-site-packages env
