#!/usr/bin/env bash

chmod +x /etc/update-motd.d/*
ln -s /usr/share/landscape/landscape-sysinfo.wrapper /etc/update-motd.d/50-landscape-sysinfo
