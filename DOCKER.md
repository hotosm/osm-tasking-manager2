## Docker

Add the following to ~/.ssh/config. This makes it easier to download backups from amelia.
```
Host amelia
  Hostname 144.76.31.210
  User root
  Port 43432
  IdentityFile ~/path_to_ssh_key
```

Download backup from amelia (if needed). The `/tmp/docker_tmp/` directory will be created by rsync.
`rsync -arvz --progress amelia:$(ssh amelia "ls -Art /pg_dump/osmtm2* | tail -n 1") /tmp/docker_tmp/osmtm2.dmp`

Start Docker
`docker-compose up -d`

restore database (this step is currently broken)
```
docker-compose exec db su - postgres -c "pg_restore \
  --verbose \
  --dbname=osmtm \
  --jobs=8 \
  --clean \
  /srv/osmtm2.dmp"
```

Monitor database restore in another window
`docker-compose exec db su - postgres -c "pg_top"`
