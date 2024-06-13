#!/bin/bash

cd "$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)"
mkdir -p /var/app/bundle
ln -s /var/app/bundle vendor

mkdir -p tmp/amr_files_bucket
chown webapp:webapp tmp/amr_files_bucket
chown webapp:webapp tmp
