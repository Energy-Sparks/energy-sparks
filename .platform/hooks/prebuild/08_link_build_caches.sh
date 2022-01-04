#!/bin/bash
app="$(/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir)";

if [ ! -d "/var/cache/node_modules" ]; then
  mkdir /var/cache/node_modules ;
  chown webapp:webapp /var/cache/node_modules;
fi
ln -s /var/cache/node_modules "${app}";

if [ ! -d "/var/cache/bundle" ]; then
  mkdir /var/cache/bundle;
  chown webapp:webapp /var/cache/bundle;
fi
ln -s /var/cache/bundle "${app}/vendor";

if [ ! -d "/var/cache/assets" ]; then
  mkdir /var/cache/assets ;
  chown webapp:webapp /var/cache/assets;
fi
mkdir -p "${app}/tmp/cache";
chown webapp:webapp "${app}/tmp/cache"
ln -s /var/cache/assets "${app}/tmp/cache";

mkdir -p "${app}/tmp/amr_files_bucket";
chown webapp:webapp "${app}/tmp";
