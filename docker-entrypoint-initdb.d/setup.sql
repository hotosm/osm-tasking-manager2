CREATE USER "www-data" WITH PASSWORD 'password';
ALTER USER "www-data" WITH NOSUPERUSER NOCREATEROLE NOCREATEDB;
CREATE DATABASE osmtm2 OWNER "www-data" ENCODING 'UTF8' TEMPLATE template0;
\connect osmtm2
CREATE EXTENSION postgis;
SELECT postgis_full_version();
