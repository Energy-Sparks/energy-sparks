#!/bin/bash
# Install dependencies
app="$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)";
cd "${app}";
yarn install
chown -R webapp:webapp node_modules
