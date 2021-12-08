#!/usr/bin/env bash
set -xe

#EB_SCRIPT_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k script_dir)
EB_APP_STAGING_DIR=$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)
EB_APP_USER=$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppUser)
#EB_SUPPORT_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k support_dir)

#. $EB_SUPPORT_DIR/envvars-wrapper.sh

#RAKE_TASK="after_party:run"

#. $EB_SCRIPT_DIR/use-app-ruby.sh

cd $EB_APP_STAGING_DIR

su -s /bin/bash -c "leader_only bundle exec rails after_party:run" $EB_APP_USER
