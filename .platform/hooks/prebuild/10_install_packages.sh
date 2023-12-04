#!/bin/bash
# Install dependencies
app="$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)";
cd "${app}";
corepack yarn
#yarn install
chown webapp:webapp node_modules/.yarn-integrity
