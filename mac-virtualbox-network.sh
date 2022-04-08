#!/usr/bin/env bash

# https://www.virtualbox.org/manual/ch06.html#network_hostonly
echo "This script needs root access."
sudo mkdir -p /etc/vbox
sudo sh -c "echo \"* 0.0.0.0/0 ::/0\" >/etc/vbox/networks.conf"