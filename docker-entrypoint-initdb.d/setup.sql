CREATE USER "taskmanv2" WITH PASSWORD 'password';
-- ALTER USER "taskmanv2" WITH NOSUPERUSER NOCREATEROLE NOCREATEDB;
ALTER USER "taskmanv2" WITH SUPERUSER;
CREATE DATABASE osmtm OWNER "taskmanv2" ENCODING 'UTF8' TEMPLATE template0;
\connect osmtm
-- CREATE EXTENSION postgis;
-- SELECT postgis_full_version();
