#!/bin/bash
set -euo pipefail

install -d /opt/trucksuite/logs
python3 -m venv /opt/trucksuite/venv
source /opt/trucksuite/venv/bin/activate
pip install --upgrade pip
pip install python-can can-isotp
deactivate

# Bring-up helper
install -Dm755 /opt/trucksuite/can.sh /opt/trucksuite/can.sh

# Wrapper
cat >/usr/local/bin/trucksuite <<'EOF'
#!/usr/bin/env bash
source /opt/trucksuite/venv/bin/activate
exec python /opt/trucksuite/trucksuite.py "$@"
EOF
chmod +x /usr/local/bin/trucksuite

# Bring CAN up safely at boot (listen-only 500k)
cat >/etc/systemd/system/can-setup.service <<'EOF'
[Unit]
Description=Bring up can0 (safe listen-only @500k)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/trucksuite/can.sh 500000 listen

[Install]
WantedBy=multi-user.target
EOF
systemctl enable can-setup.service
