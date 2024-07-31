#!/bin/sh

tar czf - /var/app/bundle | aws s3 cp - s3://elasticbeanstalk-eu-west-2-110304303563/bundle-$(/opt/elasticbeanstalk/bin/get-config container -k environment_name).tar.gz
