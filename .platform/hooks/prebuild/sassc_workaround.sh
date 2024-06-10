#!/bin/sh
set -xe

exit 0

# from
# https://stackoverflow.com/questions/77496256/elasticbeanstalk-ruby-3-2-2-platform-sassc-loaderror
# https://github.com/sass/sassc-ruby/issues/146

# The following two lines replicate what Beanstalk does by default to load the gems.
# This installs all the gems in ./vendor/bundle.
bundle config set --local deployment true
bundle _2.4.10_ install

cd vendor/bundle/ruby/3.2.0/gems/sassc-2.4.0/lib/sassc
ln -s ../../../../extensions/aarch64-linux/3.2.0/sassc-2.4.0/sassc/libsass.so libsass.so
