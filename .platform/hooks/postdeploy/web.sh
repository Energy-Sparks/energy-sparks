#!/bin/sh

mkdir -p /etc/systemd/system/web.service.d
cat <<EOF >/etc/systemd/system/web.service.d/override.conf
[Service]
Nice=-10
EOF
