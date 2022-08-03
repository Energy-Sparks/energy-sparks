#!/usr/bin/env bash
set -xe

EB_APP_STAGING_DIR=$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)
EB_APP_USER=$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppUser)

set +x
export $(/opt/elasticbeanstalk/bin/get-config --output YAML environment | sed -r 's/: /=/' | xargs)
set -x

PATH=/opt/elasticbeanstalk/.rbenv/shims:/opt/elasticbeanstalk/.rbenv/bin:$PATH
RBENV_ROOT=/opt/elasticbeanstalk/.rbenv
RBENV_VERSION=$(cat $RBENV_ROOT/version)

cd $EB_APP_STAGING_DIR

if [ "$EB_IS_COMMAND_LEADER" = "true" ]; then
  su -s /bin/bash -c "bundle exec rails after_party:run" $EB_APP_USER
fi
