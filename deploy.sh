#!/bin/bash -eux

DEPLOY_USER="mozart"
HOST="62.210.100.219"
URL="http://tasks-staging.hotosm.org"

connect to zoonmaps server and ensure things are setup
ssh $DEPLOY_USER@$HOST -i mozart_rsa \
    -o "ForwardAgent=yes" \
    "if cd /srv/deploy/osm-tasking-manager2 ; then \
        git pull \
        && git submodule update --init -f ; \
    else \
        sudo mkdir -p /srv/deploy \
        && sudo chown -R /srv/deploy \
        && git clone --recursive -b docker-2.13 \
            git@github.com:hotosm/osm-tasking-manager2.git \
            /srv/deploy/osm-tasking-manager2;
    fi"

# rsync -arvz --progress . \
#  -e "ssh -o StrictHostKeyChecking=no \
#          -o UserKnownHostsFile=/dev/null \
#          -i mozart_rsa" \
# $DEPLOY_USER@$HOST:/srv/deploy/osm-tasking-manager2

# find the live environment
LIVE_COLOR=$(ssh $DEPLOY_USER@$HOST -i mozart_rsa "docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  ps | \
  awk '/app.*Up/ {print $1}'")

# set values for live color and deploy color
if [[ $LIVE_COLOR == *"blue"* ]]; then
  deploy="green";
  live="blue"
elif [[ $LIVE_COLOR == *"green"* ]]; then
  deploy="blue";
  live="green"
else
  echo "app not running"
fi

# build new color
ssh $DEPLOY_USER@$HOST -i mozart_rsa \
  "docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  build app app_$deploy"

# deploy new color
ssh $DEPLOY_USER@$HOST -i mozart_rsa \
  "docker-compose \
    -f docker-compose.yml \
    -f docker-compose.production.yml \
    up -d \
    --force-recreate app_$deploy"

# Wait a little in case the service takes a bit to start
sleep 5

# test new server alt url
until $(curl --output /dev/null --silent --head --fail http://tasks-staging-$deploy.hotosm.org); do
    printf '.'
    sleep 2
done

# stop old server
ssh $DEPLOY_USER@$HOST -i mozart_rsa \
  "docker-compose \
    -f docker-compose.yml \
    -f docker-compose.production.yml \
    stop app_$live"

# test main site
until $(curl --output /dev/null --silent --head --fail ${URL}); do
    printf '.'
    sleep 2
done
