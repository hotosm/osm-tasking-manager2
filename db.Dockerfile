FROM library/postgres

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      postgis \
      postgresql-9.6-postgis-2.3 \
      postgresql-contrib-9.6 \
      postgresql-9.6-postgis-scripts

COPY docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

RUN dpkg-query -l postgis

RUN ls -lAh /usr/share/postgresql/9.6/extension/postgis*
