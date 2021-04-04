#!/usr/bin/env bash

chmod 600 $(pwd)/ssh/* 2>/dev/null
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $(pwd)/ssh/id_rsa vagrant@192.168.10.${1:-100}
