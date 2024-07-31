#!/bin/bash

if ! [ -d /var/app/bundle ]; then
  aws s3 cp s3://elasticbeanstalk-eu-west-2-110304303563/bundle-$(/opt/elasticbeanstalk/bin/get-config container -k environment_name).tar.gz - | tar xzC /
fi
mkdir -p /var/app/bundle

cd "$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)"
ln -s /var/app/bundle vendor

mkdir -p tmp/amr_files_bucket
chown webapp:webapp tmp/amr_files_bucket
chown webapp:webapp tmp
