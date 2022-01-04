#!/usr/bin/env bash
set -xe

EB_APP_STAGING_DIR=$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)
EB_APP_USER=$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppUser)

set +x
export $(cat /opt/elasticbeanstalk/deployment/env | xargs)
set -x

cd $EB_APP_STAGING_DIR

if [ "$EB_IS_COMMAND_LEADER" = "true" ]; then
  su -s /bin/bash -c "bundle exec rails after_party:run" $EB_APP_USER
fi
