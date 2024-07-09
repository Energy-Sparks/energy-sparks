#!/usr/bin/env bash
set -e
export $(< /opt/elasticbeanstalk/deployment/env)
set -x
EB_APP_STAGING_DIR="$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)"
EB_APP_USER="$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppUser)"
if [ "$EB_IS_COMMAND_LEADER" = "true" ]; then
  cd "$EB_APP_STAGING_DIR"
  runuser -u "$EB_APP_USER" -- bin/rails after_party:run
fi
