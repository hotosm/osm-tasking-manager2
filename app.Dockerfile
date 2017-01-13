FROM python:2.7.12

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      libgeos-dev

ADD requirements.txt /opt/app/requirements.txt
ADD setup.py /opt/app/setup.py
ADD setup.cfg /opt/app/setup.cfg
ADD README.md /opt/app/README.md
ADD CHANGELOG.md /opt/app/CHANGELOG.md

WORKDIR /opt/app

RUN easy_install virtualenv
RUN virtualenv --no-site-packages env
RUN ./env/bin/pip install -r requirements.txt
RUN ./env/bin/pip install html5lib==0.999
# RUN ./env/bin/python setup.py develop

ADD . /opt/app

# RUN ls -lAht /opt/app/osmtm/static/js/lib/showdown/dist/showdown.js

CMD ./env/bin/initialize_osmtm_db && ./env/bin/pserve --reload development.ini
# CMD ./env/bin/pserve --reload development.ini
