#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y git
$STD apt-get install -y wget
$STD apt-get install -y openssh-server
msg_ok "Installed Dependencies"

msg_info "Installing Golang"
set +o pipefail
wget -q https://golang.org/dl/go1.22.2.linux-arm64.tar.gz
tar -xzf go1.22.2.linux-arm64.tar.gz -C /usr/local
$STD ln -s /usr/local/go/bin/go /usr/local/bin/go
set -o pipefail
msg_ok "Installed Golang"

msg_info "Installing Zoraxy (Patience)"
$STD git clone https://github.com/tobychui/zoraxy /opt/zoraxy
cd /opt/zoraxy/src
$STD go mod tidy
$STD go build
msg_ok "Installed Zoraxy"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/zoraxy.service
[Unit]
Description=General purpose request proxy and forwarding tool
After=syslog.target network-online.target

[Service]
ExecStart=/opt/zoraxy/src/./zoraxy
WorkingDirectory=/opt/zoraxy/src/
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now zoraxy.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf go1.22.2.linux-arm64.tar.gz
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
