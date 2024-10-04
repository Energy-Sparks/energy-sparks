#!/bin/bash

# create override file in case of system restart but probably won't be used
mkdir -p /etc/systemd/system/web.service.d
cat <<EOF >/etc/systemd/system/web.service.d/override.conf
[Service]
Nice=-10
EOF

renice -10 -g $(< /var/pids/web.pid)
