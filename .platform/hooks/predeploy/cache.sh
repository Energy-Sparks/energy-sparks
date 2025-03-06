#!/bin/sh

[ -f /keep_cache ] && exit 0

set -e
# /opt/elasticbeanstalk/deployment/env doesn't exist on a new instance
export $(/opt/elasticbeanstalk/bin/get-config environment | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
cd "$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)"
runuser -u "$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppUser)" -- bin/rails r Rails.cache.clear
