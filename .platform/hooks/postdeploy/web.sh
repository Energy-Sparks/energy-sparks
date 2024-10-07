#!/bin/bash

# create override file in case of system restart but probably won't be used
# elasticbeantalk removes the override when disabling the service on deploy
mkdir -p /etc/systemd/system/web.service.d
cat <<EOF >/etc/systemd/system/web.service.d/override.conf
[Service]
Nice=-10
EOF
systemctl daemon-reload

renice -10 -g $(< /var/pids/web.pid)
