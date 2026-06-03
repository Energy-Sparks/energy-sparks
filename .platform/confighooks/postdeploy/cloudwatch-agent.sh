#!/bin/sh

# for some reason this isn't always started after stopping during deploy
systemctl start amazon-cloudwatch-agent
