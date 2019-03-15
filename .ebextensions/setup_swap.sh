#!/bin/bash

SWAPFILE=/var/swapfile
SWAP_MEGABYTES=2048

if [ -f $SWAPFILE ]; then
	echo "Swapfile $SWAPFILE found, assuming already setup"
  if [[ $(swapon -s) ]]
  then
    echo "Swapfile $SWAPFILE found, and already setup"
  else
    echo "Swapfile $SWAPFILE found, but not enabled, enable now"
    /sbin/swapon $SWAPFILE
  fi
	exit;
else
  echo "No swapfile found, so create and setup"
  /bin/dd if=/dev/zero of=$SWAPFILE bs=1M count=$SWAP_MEGABYTES
  /bin/chmod 600 $SWAPFILE
  /sbin/mkswap $SWAPFILE
  /sbin/swapon $SWAPFILE
fi
