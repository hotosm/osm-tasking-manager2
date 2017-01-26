#!/bin/bash -eux

DEPLOY_USER="mozart"
HOST="62.210.100.219"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i mozart_rsa -o ForwardAgent=yes -o IPQoS=throughput -tt"
BASE_DIR="/srv/deploy/osm-tasking-manager2"

# download mozarts key
aws s3 cp s3://hotosm-secure/keys/mozart_rsa.enc mozart_rsa.enc
# unencrypt mozarts key
openssl aes-256-cbc -K $encrypted_e101044e37e0_key -iv $encrypted_e101044e37e0_iv \
  -in mozart_rsa.enc -out mozart_rsa -d
# fix permissions
chmod 700 mozart_rsa

# set environment variable based on branch or tag
if [ ! -z $TRAVIS_TAG ]; then
  echo "Deploying $TRAVIS_TAG to prod"
  URL_PREFIX="tasks"
  ENV="production"
elif [ "$TRAVIS_BRANCH" == "develop" -o "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Deploying develop branch to staging"
  URL_PREFIX="tasks-staging"
  ENV="staging"
else
  echo "Not a tag or develop branch. Doing nothing"
  exit 0
fi

# rsync files to server and respective environment path
rsync -arvz --delete --progress . \
 --exclude='.git/' \
 -e "ssh -o StrictHostKeyChecking=no \
         -o UserKnownHostsFile=/dev/null \
         -i mozart_rsa" \
$DEPLOY_USER@$HOST:$BASE_DIR-$ENV

# find the live environment
LIVE_COLOR=$(ssh $SSH_OPTS $DEPLOY_USER@$HOST \
  "sudo su -c 'cd $BASE_DIR-$ENV && docker-compose \
  -f docker-compose.yml \
  -f docker-compose.$ENV.yml \
  ps'" | awk '/app.*Up/ {print $1}')

# set values for live color and deploy color
if [[ $LIVE_COLOR == *"blue"* ]]; then
  deploy="green"; live="blue"
elif [[ $LIVE_COLOR == *"green"* ]]; then
  deploy="blue"; live="green"
else
  echo "app not running"
fi

# echo build color
echo "building app_$deploy"

# build new color
ssh $DEPLOY_USER@$HOST $SSH_OPTS \
  "sudo su -c 'cd $BASE_DIR-$ENV && docker-compose \
  -f docker-compose.yml \
  -f docker-compose.$ENV.yml \
  build app app_$deploy'"

# echo deploy color
echo "deploying app_$deploy"

# deploy new color
ssh $DEPLOY_USER@$HOST $SSH_OPTS \
  "sudo su -c 'cd $BASE_DIR-$ENV && docker-compose \
    -f docker-compose.yml \
    -f docker-compose.$ENV.yml \
    up -d \
    --force-recreate app_$deploy'"

# wait a little in case the service takes a bit to start
sleep 5

# test new server alt url
until $(curl --output /dev/null --silent --head --fail http://$URL_PREFIX-$deploy.hotosm.org); do
    printf '.'
    sleep 2
done

# TODO
# add timeout
# add fail check to tear down new servers

# stop old server
ssh $DEPLOY_USER@$HOST $SSH_OPTS \
  "sudo su -c 'cd $BASE_DIR-$ENV && docker-compose \
    -f docker-compose.yml \
    -f docker-compose.$ENV.yml \
    stop app_$live'"

# test main site
until $(curl --output /dev/null --silent --head --fail http://$URL_PREFIX.hotosm.org); do
    printf '.'
    sleep 2
done
