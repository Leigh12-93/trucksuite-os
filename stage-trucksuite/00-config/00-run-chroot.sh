#!/bin/bash
set -euo pipefail

# Detect boot config path (Bookworm uses /boot/firmware)
BOOTCFG="/boot/firmware/config.txt"
[ -f /boot/config.txt ] && BOOTCFG="/boot/config.txt"

# Enable SPI & MCP2515 overlay for Crow Terminal (adjust INT if needed)
grep -q '^dtparam=spi=on' "$BOOTCFG" || echo 'dtparam=spi=on' >> "$BOOTCFG"
if ! grep -q '^dtoverlay=mcp2515' "$BOOTCFG"; then
  echo 'dtoverlay=mcp2515,spi0-0,oscillator=16000000,interrupt=25' >> "$BOOTCFG"
  echo 'dtoverlay=spi-bcm2835' >> "$BOOTCFG"
fi

# Modules (CAN + ISO-TP)
cat >/etc/modules-load.d/can.conf <<'EOF'
can
can_raw
can_dev
can-isotp
EOF

# Allow pi to run trucksuite without sudo password
mkdir -p /etc/sudoers.d
cat >/etc/sudoers.d/trucksuite <<'EOF'
pi ALL=(ALL) NOPASSWD: /usr/local/bin/trucksuite, /opt/trucksuite/*
EOF
chmod 440 /etc/sudoers.d/trucksuite

# Autologin to tty1 and auto-run trucksuite
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
EOF

# Auto-run trucksuite on tty1 shell
mkdir -p /home/pi
chown -R pi:pi /home/pi
cat >/home/pi/.bash_profile <<'EOF'
if [ -t 0 ] && [ "$(tty)" = "/dev/tty1" ]; then
  clear
  echo "Launching TruckSuite... (Ctrl+C to drop to shell)"
  sudo trucksuite
fi
EOF
chown pi:pi /home/pi/.bash_profile
