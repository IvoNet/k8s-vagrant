#!/bin/bash
sudo swapoff -a
echo "Installing dependencies. This may take a while..."
sudo apt-get update -q -y
sudo apt-get upgrade -q -y
sudo apt-get install -q -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"
sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
sudo apt-get update -q -y
sudo apt-get install -q -y kubeadm=1.20.1-00 kubelet=1.20.1-00 kubectl=1.20.1-00
sudo apt-mark hold kubelet kubeadm kubectl

sudo sed -i "s/KUBELET_CONFIG_ARGS=/KUBELET_CONFIG_ARGS=--node-ip=$(ifconfig|grep 'inet 192.168.10.1'|awk '{print $2}'|xargs echo -n) /g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo "Finished."
echo "NOTE:Now apply the 'kubeadm join' command from the master install."