#!/bin/sh

# https://github.com/aws/elastic-beanstalk-roadmap/issues/139
cd "$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)"
bundle config set --local path /var/app/bundle
