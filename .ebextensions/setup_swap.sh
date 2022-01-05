#!/bin/bash

SWAPFILE=/var/swapfile
SWAP_MEGABYTES=1024

BIGSWAPFILE=/var/bigswapfile
BIGSWAP_MEGABYTES=4096

if [ -f $BIGSWAPFILE ]; then
  echo "Big swapfile $BIGSWAPFILE found, assuming already setup"
  if [[ $(swapon -s) ]]
  then
    echo "Big swapfile $SWAPFILE found, and already setup"
  else
    echo "Big swapfile $SWAPFILE found, but not enabled, enable now"
    /sbin/swapon $BIGSWAPFILE
  fi
  exit;
else
  echo "No big swapfile found, so create and setup"
  /bin/dd if=/dev/zero of=$BIGSWAPFILE bs=1M count=$BIGSWAP_MEGABYTES
  /bin/chmod 600 $BIGSWAPFILE
  /sbin/mkswap $BIGSWAPFILE
  /sbin/swapon $BIGSWAPFILE
fi

if [ -f $SWAPFILE ]; then
  echo "Swapfile $SWAPFILE found, assuming already setup, switch off swap and delete"
  if [[ $(swapon -s) ]]
  then
    echo "Swapfile $SWAPFILE found, switch off swap"
    /sbin/swapoff $SWAPFILE
  fi
  echo "Swapfile $SWAPFILE found, not swapping, so delete"
  /bin/rm -rf $SWAPFILE
  exit;
fi
