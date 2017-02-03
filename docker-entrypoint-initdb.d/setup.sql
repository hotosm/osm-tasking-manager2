CREATE USER "www-data" WITH PASSWORD 'password';
-- ALTER USER "www-data" WITH NOSUPERUSER NOCREATEROLE NOCREATEDB;
ALTER USER "www-data" WITH SUPERUSER;
CREATE DATABASE osmtm OWNER "www-data" ENCODING 'UTF8' TEMPLATE template0;
\connect osmtm
-- CREATE EXTENSION postgis;
-- SELECT postgis_full_version();
