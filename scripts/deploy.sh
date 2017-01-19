#!/bin/bash -eux

DEPLOY_USER="mozart"
HOST="62.210.100.219"
URL="http://tasks-staging.hotosm.org"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i mozart_rsa -o ForwardAgent=yes -o IPQoS=throughput -tt"
BASE_DIR="/srv/deploy/osm-tasking-manager2"

echo "step 1"
# download mozarts key
aws s3 cp s3://hotosm-secure/keys/mozart_rsa.enc mozart_rsa.enc

echo "step 2"
# unencrypt mozarts key
openssl aes-256-cbc -K $encrypted_e101044e37e0_key -iv $encrypted_e101044e37e0_iv \
  -in mozart_rsa.enc -out mozart_rsa -d

echo "step 3"
# fix permissions
chmod 700 mozart_rsa

# connect to zoonmaps server and ensure things are setup
# ssh-add mozart_rsa; ssh $DEPLOY_USER@$HOST $SSH_OPTS \
#     -o "ForwardAgent=yes" \
#     "if cd /srv/deploy/osm-tasking-manager2 ; then \
#         git pull \
#         && git submodule update --init -f ; \
#     else \
#         sudo mkdir -p /srv/deploy \
#         && sudo chown -R /srv/deploy \
#         && git clone --recursive -b docker-2.13 \
#             git@github.com:hotosm/osm-tasking-manager2.git \
#             /srv/deploy/osm-tasking-manager2;
#     fi"

# ssh $DEPLOY_USER@$HOST $SSH_OPTS \
#     "ssh-add -l"

rsync -arvz --progress . \
 -e "ssh -o StrictHostKeyChecking=no \
         -o UserKnownHostsFile=/dev/null \
         -i mozart_rsa" \
$DEPLOY_USER@$HOST:$BASE_DIR

# find the live environment
LIVE_COLOR=$(ssh $SSH_OPTS $DEPLOY_USER@$HOST \
"sudo su -c 'cd $BASE_DIR && docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  ps'" | awk '/app.*Up/ {print $1}')

echo "$LIVE_COLOR is live"

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

echo "building app_$deploy"

# build new color
ssh $DEPLOY_USER@$HOST $SSH_OPTS \
  "sudo su -c 'cd $BASE_DIR && docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  build app app_$deploy"

echo "deploying app_$deploy"

# deploy new color
ssh $DEPLOY_USER@$HOST $SSH_OPTS \
  "sudo su -c 'cd $BASE_DIR && docker-compose \
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
ssh $DEPLOY_USER@$HOST $SSH_OPTS \
  "sudo su -c 'cd $BASE_DIR && docker-compose \
    -f docker-compose.yml \
    -f docker-compose.production.yml \
    stop app_$live"

# test main site
until $(curl --output /dev/null --silent --head --fail ${URL}); do
    printf '.'
    sleep 2
done
