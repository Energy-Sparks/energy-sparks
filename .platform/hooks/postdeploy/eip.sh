#!/bin/sh

[ -z "$EIP_ALLOCATION_ID" ] && exit 0

unset AWS_ACCESS_KEY_ID # use instance role rather than environment

aws ec2 associate-address --instance-id "$(ec2-metadata --quiet -i)" --allocation-id "$EIP_ALLOCATION_ID"
