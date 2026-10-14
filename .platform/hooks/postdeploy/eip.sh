#!/bin/sh

[ -z "$EIP_ALLOCATION_ID" ] && exit 0

aws ec2 associate-address --instance-id "$(ec2-metadata --quiet -i)" --allocation-id "$EIP_ALLOCATION_ID"
