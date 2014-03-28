# FIXME Python 2.7 is hardcoded


.PHONY: all
all: install

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Possible targets:"
	@echo ""
	@echo "- install				Install the project's dev egg in a virtual env"
	@echo "- check					Execute flake8 and nosetests"
	@echo "- help					Display this help"
	@echo ""

.PHONY: check
check: flake8 nosetests

.PHONY: install
install: .build/env .build/env/lib/python2.7/site-packages/mapnik
	.build/env/bin/python setup.py develop > /dev/null

.PHONY: flake8
flake8: .build/env/bin/flake8
	.build/env/bin/flake8 osmtm

.PHONY: nosetests
nosetests: install
	.build/env/bin/nosetests

.build/env/bin/flake8: .build/env
	.build/env/bin/easy_install flake8

.build/env/lib/python2.7/site-packages/mapnik: .build/env
	ln -sf `python -c 'import mapnik, os.path; print(os.path.dirname(mapnik.__file__))'` $(dir $@)

.build/env:
	mkdir -p .build
	virtualenv --no-site-packages $@
